import 'package:flutter/material.dart';

/// Website URL Routes - Maps app sections to website URLs
class WebsiteRoutes {
  static const String baseUrl = 'https://www.comunidadeislamica.pt';

  // Main pages
  static const String home = baseUrl;
  static const String news = '$baseUrl/noticias';
  static const String events = '$baseUrl/eventos';
  static const String aboutIslam = '$baseUrl/sobre-o-islao';
  static const String calendar = '$baseUrl/calendario';
  static const String contacts = '$baseUrl/contactos';
  static const String donation = '$baseUrl/donativo';
  static const String membership = '$baseUrl/adesao';
  static const String wedding = '$baseUrl/casamento';

  // About section
  static const String aboutCil = '$baseUrl/cil';
  static const String aboutMosque = '$baseUrl/mesquita';
  static const String history = '$baseUrl/historia';
  static const String activities = '$baseUrl/actividades';

  // Islamic education
  static const String pillarsOfIslam = '$baseUrl/pilares-do-islao';
  static const String prayer = '$baseUrl/oracao';
  static const String quran = '$baseUrl/alcorao';
  static const String ramadan = '$baseUrl/ramadao';
  static const String hajj = '$baseUrl/hajj';
  static const String zakat = '$baseUrl/zakat';

  // Services
  static const String funeralServices = '$baseUrl/servicos-funebres';
  static const String educationServices = '$baseUrl/educacao';
  static const String socialServices = '$baseUrl/accao-social';
  static const String youthServices = '$baseUrl/juventude';

  // Blog/RSS
  static const String blog = '$baseUrl/blog';
  static const String rssFeed = '$baseUrl/blog-feed.xml';

  // Social media
  static const String facebook = 'https://www.facebook.com/cilisboa';
  static const String instagram = 'https://www.instagram.com/comunidade_islamica_lisboa';
  static const String youtube = 'https://www.youtube.com/@cilisboa';

  // Language variants
  static String getLocalizedUrl(String path, String languageCode) {
    switch (languageCode) {
      case 'en':
        return '$baseUrl/en$path';
      case 'fr':
        return '$baseUrl/fr$path';
      default:
        return '$baseUrl$path';
    }
  }
}

/// Website Navigation Item
class WebsiteNavItem {
  final String title;
  final String url;
  final IconData icon;
  final List<WebsiteNavItem>? subItems;

  const WebsiteNavItem({
    required this.title,
    required this.url,
    required this.icon,
    this.subItems,
  });
}

/// Website Service - Manages website integration
class WebsiteService {
  /// Get all navigation items matching the website structure
  static List<WebsiteNavItem> getNavigationItems() {
    return [
      const WebsiteNavItem(
        title: 'Início',
        url: WebsiteRoutes.home,
        icon: Icons.home,
      ),
      const WebsiteNavItem(
        title: 'Notícias',
        url: WebsiteRoutes.news,
        icon: Icons.newspaper,
        subItems: [
          WebsiteNavItem(
            title: 'Todas as Notícias',
            url: WebsiteRoutes.news,
            icon: Icons.article,
          ),
          WebsiteNavItem(
            title: 'Eventos',
            url: WebsiteRoutes.events,
            icon: Icons.event,
          ),
        ],
      ),
      const WebsiteNavItem(
        title: 'Sobre o Islão',
        url: WebsiteRoutes.aboutIslam,
        icon: Icons.menu_book,
        subItems: [
          WebsiteNavItem(
            title: 'Pilares do Islão',
            url: WebsiteRoutes.pillarsOfIslam,
            icon: Icons.star,
          ),
          WebsiteNavItem(
            title: 'Oração',
            url: WebsiteRoutes.prayer,
            icon: Icons.access_time,
          ),
          WebsiteNavItem(
            title: 'Alcorão',
            url: WebsiteRoutes.quran,
            icon: Icons.auto_stories,
          ),
          WebsiteNavItem(
            title: 'Ramadão',
            url: WebsiteRoutes.ramadan,
            icon: Icons.nightlight_round,
          ),
          WebsiteNavItem(
            title: 'Hajj',
            url: WebsiteRoutes.hajj,
            icon: Icons.mosque,
          ),
          WebsiteNavItem(
            title: 'Zakat',
            url: WebsiteRoutes.zakat,
            icon: Icons.volunteer_activism,
          ),
        ],
      ),
      const WebsiteNavItem(
        title: 'Calendário',
        url: WebsiteRoutes.calendar,
        icon: Icons.calendar_month,
      ),
      const WebsiteNavItem(
        title: 'Contactos',
        url: WebsiteRoutes.contacts,
        icon: Icons.contact_mail,
      ),
      const WebsiteNavItem(
        title: 'Donativo',
        url: WebsiteRoutes.donation,
        icon: Icons.favorite,
      ),
      const WebsiteNavItem(
        title: 'Adesão',
        url: WebsiteRoutes.membership,
        icon: Icons.card_membership,
      ),
      const WebsiteNavItem(
        title: 'Casamento',
        url: WebsiteRoutes.wedding,
        icon: Icons.favorite_border,
      ),
    ];
  }

  /// Get URL for a specific page type
  static String getPageUrl(String pageType, {String? id, String languageCode = 'pt'}) {
    switch (pageType) {
      case 'news':
        return id != null ? '${WebsiteRoutes.news}/$id' : WebsiteRoutes.news;
      case 'event':
        return id != null ? '${WebsiteRoutes.events}/$id' : WebsiteRoutes.events;
      case 'donation':
        return WebsiteRoutes.donation;
      case 'membership':
        return WebsiteRoutes.membership;
      case 'wedding':
        return WebsiteRoutes.wedding;
      case 'contact':
        return WebsiteRoutes.contacts;
      case 'about':
        return WebsiteRoutes.aboutCil;
      case 'calendar':
        return WebsiteRoutes.calendar;
      default:
        return WebsiteRoutes.home;
    }
  }

  /// Check if URL is from CIL website
  static bool isCilUrl(String url) {
    return url.contains('comunidadeislamica.pt');
  }

  /// Extract page type from URL
  static String? getPageTypeFromUrl(String url) {
    if (url.contains('/noticias') || url.contains('/post/')) return 'news';
    if (url.contains('/eventos')) return 'event';
    if (url.contains('/donativo')) return 'donation';
    if (url.contains('/adesao')) return 'membership';
    if (url.contains('/casamento')) return 'wedding';
    if (url.contains('/contactos')) return 'contact';
    if (url.contains('/calendario')) return 'calendar';
    if (url.contains('/sobre') || url.contains('/cil')) return 'about';
    return null;
  }
}
