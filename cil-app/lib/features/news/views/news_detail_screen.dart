import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/news_service.dart';
import '../../../core/utils/url_helper.dart';

class NewsDetailScreen extends StatelessWidget {
  final String newsId;

  const NewsDetailScreen({super.key, required this.newsId});

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, provider, _) {
        final news = provider.news?.firstWhere(
          (n) => n.id == newsId,
          orElse: () => NewsItem(
            id: '',
            title: '',
            content: '',
            summary: '',
            imageUrl: '',
            publishedAt: DateTime.now(),
            author: '',
            category: '',
            tags: [],
          ),
        );

        if (news == null || news.id.isEmpty) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Notícia não encontrada')),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App Bar with Image
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: news.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.primary.withOpacity(0.1),
                          child: const Icon(Icons.newspaper, size: 64, color: AppColors.primary),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  if (news.webUrl.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.open_in_browser),
                      tooltip: 'Ver no Website',
                      onPressed: () {
                        UrlHelper.openUrl(context, news.webUrl, title: news.title);
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      final shareUrl = news.webUrl.isNotEmpty
                          ? news.webUrl
                          : '${AppConstants.websiteUrl}/noticias';
                      Share.share(
                        '${news.title}\n\n${news.summary}\n\n$shareUrl',
                        subject: news.title,
                      );
                    },
                  ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category & Date
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              news.category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd MMMM yyyy', 'pt_PT').format(news.publishedAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        news.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Author
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              news.author.isNotEmpty ? news.author[0].toUpperCase() : 'C',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            news.author.isNotEmpty ? news.author : 'CIL',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Content
                      Text(
                        news.content,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tags
                      if (news.tags.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: news.tags.map((tag) => Chip(
                            label: Text('#$tag'),
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            labelStyle: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
                          )).toList(),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // View on Website Button
                      if (news.webUrl.isNotEmpty) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              UrlHelper.openUrl(context, news.webUrl, title: news.title);
                            },
                            icon: const Icon(Icons.open_in_browser),
                            label: const Text('Ver Artigo Completo no Website'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Share Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.share, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Partilhe esta notícia',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                final shareUrl = news.webUrl.isNotEmpty
                                    ? news.webUrl
                                    : '${AppConstants.websiteUrl}/noticias';
                                Share.share(
                                  '${news.title}\n\n${news.summary}\n\n$shareUrl',
                                  subject: news.title,
                                );
                              },
                              child: const Text('Partilhar'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
