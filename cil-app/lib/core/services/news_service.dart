import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import '../constants/app_constants.dart';

/// News Item Model
class NewsItem {
  final String id;
  final String title;
  final String content;
  final String summary;
  final String imageUrl;
  final DateTime publishedAt;
  final String author;
  final String category;
  final List<String> tags;
  final bool isFeatured;
  final String webUrl;

  NewsItem({
    required this.id,
    required this.title,
    required this.content,
    required this.summary,
    required this.imageUrl,
    required this.publishedAt,
    required this.author,
    required this.category,
    required this.tags,
    this.isFeatured = false,
    this.webUrl = '',
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      summary: json['summary'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      author: json['author'] ?? 'CIL',
      category: json['category'] ?? 'Geral',
      tags: List<String>.from(json['tags'] ?? []),
      isFeatured: json['isFeatured'] ?? false,
      webUrl: json['webUrl'] ?? '',
    );
  }

  factory NewsItem.fromRssItem(xml.XmlElement item) {
    final title = item.findElements('title').firstOrNull?.innerText ?? '';
    final link = item.findElements('link').firstOrNull?.innerText ?? '';
    final description = item.findElements('description').firstOrNull?.innerText ?? '';
    final pubDate = item.findElements('pubDate').firstOrNull?.innerText ?? '';

    // Extract image from media:content or enclosure
    String imageUrl = '';
    final mediaContent = item.findElements('media:content').firstOrNull;
    if (mediaContent != null) {
      imageUrl = mediaContent.getAttribute('url') ?? '';
    }
    final enclosure = item.findElements('enclosure').firstOrNull;
    if (imageUrl.isEmpty && enclosure != null) {
      imageUrl = enclosure.getAttribute('url') ?? '';
    }

    // Try to extract image from description HTML
    if (imageUrl.isEmpty) {
      final imgMatch = RegExp(r'src="([^"]+)"').firstMatch(description);
      if (imgMatch != null) {
        imageUrl = imgMatch.group(1) ?? '';
      }
    }

    // Parse date
    DateTime parsedDate = DateTime.now();
    try {
      parsedDate = _parseRssDate(pubDate);
    } catch (e) {
      // Use current date if parsing fails
    }

    // Clean HTML from description
    final cleanSummary = _stripHtml(description);

    // Generate ID from link
    final id = link.hashCode.toString();

    return NewsItem(
      id: id,
      title: _decodeHtmlEntities(title),
      content: description,
      summary: cleanSummary.length > 200 ? '${cleanSummary.substring(0, 200)}...' : cleanSummary,
      imageUrl: imageUrl,
      publishedAt: parsedDate,
      author: 'CIL',
      category: _extractCategory(link),
      tags: [],
      isFeatured: false,
      webUrl: link,
    );
  }

  static DateTime _parseRssDate(String dateStr) {
    // RFC 822 date format: "Mon, 01 Dec 2025 12:00:00 +0000"
    try {
      final months = {
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
        'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
      };

      final parts = dateStr.split(' ');
      if (parts.length >= 4) {
        final day = int.parse(parts[1]);
        final month = months[parts[2]] ?? 1;
        final year = int.parse(parts[3]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      // Fall through to return now
    }
    return DateTime.now();
  }

  static String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'&nbsp;'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'");
  }

  static String _extractCategory(String url) {
    if (url.contains('evento')) return 'Eventos';
    if (url.contains('educa')) return 'Educação';
    if (url.contains('social')) return 'Acção Social';
    if (url.contains('desport')) return 'Desporto';
    return 'Notícias';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'summary': summary,
      'imageUrl': imageUrl,
      'publishedAt': publishedAt.toIso8601String(),
      'author': author,
      'category': category,
      'tags': tags,
      'isFeatured': isFeatured,
      'webUrl': webUrl,
    };
  }
}

/// News Service - Fetches from CIL Website RSS Feed
class NewsService {
  static const String _rssUrl = AppConstants.rssFeedUrl;

  /// Get news from RSS feed
  Future<List<NewsItem>> getNews() async {
    try {
      final response = await http.get(
        Uri.parse(_rssUrl),
        headers: {
          'Accept': 'application/rss+xml, application/xml, text/xml',
          'User-Agent': 'CIL-App/1.0',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return _parseRssFeed(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching RSS feed: $e');
    }

    // Return cached/sample data as fallback
    return _getFallbackNews();
  }

  List<NewsItem> _parseRssFeed(String xmlString) {
    try {
      final document = xml.XmlDocument.parse(xmlString);
      final items = document.findAllElements('item');

      final newsList = items.map((item) => NewsItem.fromRssItem(item)).toList();

      // Mark first item as featured
      if (newsList.isNotEmpty) {
        newsList[0] = NewsItem(
          id: newsList[0].id,
          title: newsList[0].title,
          content: newsList[0].content,
          summary: newsList[0].summary,
          imageUrl: newsList[0].imageUrl,
          publishedAt: newsList[0].publishedAt,
          author: newsList[0].author,
          category: newsList[0].category,
          tags: newsList[0].tags,
          isFeatured: true,
          webUrl: newsList[0].webUrl,
        );
      }

      return newsList;
    } catch (e) {
      debugPrint('Error parsing RSS: $e');
      return _getFallbackNews();
    }
  }

  /// Get featured news
  Future<List<NewsItem>> getFeaturedNews() async {
    final allNews = await getNews();
    return allNews.where((n) => n.isFeatured).toList();
  }

  /// Get news by category
  Future<List<NewsItem>> getNewsByCategory(String category) async {
    final allNews = await getNews();
    return allNews.where((n) => n.category == category).toList();
  }

  /// Get single news item
  Future<NewsItem?> getNewsById(String id) async {
    final allNews = await getNews();
    try {
      return allNews.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Fallback news data (real news from website)
  List<NewsItem> _getFallbackNews() {
    return [
      NewsItem(
        id: '1',
        title: 'Actualização do Valor das Quotas - Comunidade Islâmica de Lisboa',
        content: 'Anúncio sobre ajuste das quotas de associado com efeito a partir de 1 de Janeiro de 2026.',
        summary: 'Anúncio sobre ajuste das quotas de associado com efeito a partir de 1 de Janeiro de 2026.',
        imageUrl: 'https://static.wixstatic.com/media/99b369_5776a2ced67f485e8132469785b00071~mv2.jpg',
        publishedAt: DateTime(2025, 12, 1),
        author: 'CIL',
        category: 'Comunidade',
        tags: ['quotas', 'associados'],
        isFeatured: true,
        webUrl: 'https://www.comunidadeislamica.pt/post/actualiza%C3%A7%C3%A3o-do-valor-das-quotas-comunidade-isl%C3%A2mica-de-lisboa',
      ),
      NewsItem(
        id: '2',
        title: 'Mesquita Central de Lisboa assinala 40 anos com presença do Presidente da República',
        content: 'Evento comemorativo com a presença do Presidente da República e do Ministro da Justiça.',
        summary: 'Evento comemorativo com a presença do Presidente da República e do Ministro da Justiça, destacando o diálogo inter-religioso.',
        imageUrl: 'https://static.wixstatic.com/media/99b369_2a59034e36424b0b85e4ef1ea105964a~mv2.jpg',
        publishedAt: DateTime(2025, 11, 20),
        author: 'CIL',
        category: 'Eventos',
        tags: ['40 anos', 'mesquita', 'presidente'],
        isFeatured: false,
        webUrl: 'https://www.comunidadeislamica.pt/post/mesquita-central-de-lisboa-assinala-40-anos-com-presen%C3%A7a-do-presidente-da-rep%C3%BAblica',
      ),
      NewsItem(
        id: '3',
        title: 'Homenagem aos quatro ativistas portugueses',
        content: 'Cerimónia de reconhecimento aos ativistas humanitários portugueses envolvidos numa flotilha para a Palestina.',
        summary: 'A Mesquita Central de Lisboa foi palco de um encontro de homenagem aos quatro ativistas portugueses.',
        imageUrl: 'https://static.wixstatic.com/media/99b369_ece448b9c3d448b9b5fdb20be8d5b51f~mv2.jpg',
        publishedAt: DateTime(2025, 10, 23),
        author: 'CIL',
        category: 'Comunidade',
        tags: ['homenagem', 'ativistas', 'palestina'],
        isFeatured: false,
        webUrl: 'https://www.comunidadeislamica.pt/post/a-mesquita-central-de-lisboa-foi-palco-de-um-encontro-de-homenagem-aos-quatro-ativistas-portugueses',
      ),
      NewsItem(
        id: '4',
        title: 'Nota do Patriarcado de Lisboa por ocasião do 40º aniversário',
        content: 'Mensagem do Patriarcado de Lisboa reconhecendo os 40 anos da Mesquita Central.',
        summary: 'O Patriarcado de Lisboa emitiu uma nota por ocasião do 40º aniversário da Mesquita Central de Lisboa.',
        imageUrl: 'https://static.wixstatic.com/media/99b369_1ffea7a401954fba9513c7c40ac42222~mv2.png',
        publishedAt: DateTime(2025, 10, 11),
        author: 'CIL',
        category: 'Comunidade',
        tags: ['patriarcado', '40 anos', 'diálogo'],
        isFeatured: false,
        webUrl: 'https://www.comunidadeislamica.pt/post/nota-do-patriarcado-de-lisboa-por-ocasi%C3%A3o-do-40-%C2%BA-anivers%C3%A1rio-da-mesquita-central-de-lisboa',
      ),
      NewsItem(
        id: '5',
        title: 'Comunidade Islâmica de Lisboa doa ambulância aos Bombeiros de Odivelas',
        content: 'Doação de equipamento médico aos bombeiros voluntários de Odivelas.',
        summary: 'A Comunidade Islâmica de Lisboa doou uma ambulância salva-vidas aos Bombeiros Voluntários de Odivelas.',
        imageUrl: 'https://static.wixstatic.com/media/99b369_51fde68a31c940319f9041a83c03628a~mv2.jpg',
        publishedAt: DateTime(2025, 7, 16),
        author: 'CIL',
        category: 'Acção Social',
        tags: ['doação', 'bombeiros', 'solidariedade'],
        isFeatured: false,
        webUrl: 'https://www.comunidadeislamica.pt/post/comunidade-isl%C3%A2mica-de-lisboa-doa-ambul%C3%A2ncia-salva-vidas-aos-bombeiros-volunt%C3%A1rios-de-odivelas',
      ),
      NewsItem(
        id: '6',
        title: 'Intersports 2025 - 2ª Edição',
        content: 'Segunda edição do evento desportivo realizado na Fundação Inatel.',
        summary: 'A segunda edição do Intersports 2025 foi realizada com grande sucesso.',
        imageUrl: 'https://static.wixstatic.com/media/99b369_193c70659ff54dbfb639edd64fcb8238~mv2.jpg',
        publishedAt: DateTime(2025, 6, 12),
        author: 'CIL',
        category: 'Desporto',
        tags: ['desporto', 'intersports', 'juventude'],
        isFeatured: false,
        webUrl: 'https://www.comunidadeislamica.pt/post/intersports-2025-2%C2%AA-edi%C3%A7%C3%A3o',
      ),
    ];
  }
}
