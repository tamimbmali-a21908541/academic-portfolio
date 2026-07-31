import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/navigation_service.dart';

/// URL Helper - Utilities for opening URLs and navigating to website pages
class UrlHelper {
  static const String cilBaseUrl = 'https://www.comunidadeislamica.pt';

  /// Open a URL in WebView within the app
  static void openInWebView(BuildContext context, String url, {String? title}) {
    final encodedUrl = Uri.encodeComponent(url);
    final encodedTitle = title != null ? Uri.encodeComponent(title) : '';
    context.push('${AppRoutes.webview}?url=$encodedUrl&title=$encodedTitle');
  }

  /// Open a URL in the external browser
  static Future<void> openInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Open a website URL - decides whether to use WebView or browser
  static Future<void> openUrl(
    BuildContext context,
    String url, {
    String? title,
    bool preferWebView = true,
  }) async {
    if (preferWebView && isCilUrl(url)) {
      openInWebView(context, url, title: title);
    } else {
      await openInBrowser(url);
    }
  }

  /// Check if URL is from CIL website
  static bool isCilUrl(String url) {
    return url.contains('comunidadeislamica.pt') ||
        url.contains('wixstatic.com');
  }

  /// Open phone dialer
  static Future<void> openPhone(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Open email client
  static Future<void> openEmail(String email, {String? subject, String? body}) async {
    final queryParams = <String, String>{};
    if (subject != null) queryParams['subject'] = subject;
    if (body != null) queryParams['body'] = body;

    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Open WhatsApp
  static Future<void> openWhatsApp(String phoneNumber, {String? message}) async {
    final phone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    String url = 'https://wa.me/$phone';
    if (message != null) {
      url += '?text=${Uri.encodeComponent(message)}';
    }
    await openInBrowser(url);
  }

  /// Open maps with address
  static Future<void> openMaps(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final url = 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
    await openInBrowser(url);
  }

  /// Open maps with coordinates
  static Future<void> openMapsCoordinates(double lat, double lng, {String? label}) async {
    String url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (label != null) {
      url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(label)}@$lat,$lng';
    }
    await openInBrowser(url);
  }

  /// Get website page URL
  static String getPageUrl(String page) {
    final pages = {
      'home': cilBaseUrl,
      'news': '$cilBaseUrl/noticias',
      'events': '$cilBaseUrl/eventos',
      'about': '$cilBaseUrl/cil',
      'about-islam': '$cilBaseUrl/sobre-o-islao',
      'calendar': '$cilBaseUrl/calendario',
      'contact': '$cilBaseUrl/contactos',
      'donation': '$cilBaseUrl/donativo',
      'membership': '$cilBaseUrl/adesao',
      'wedding': '$cilBaseUrl/casamento',
      'education': '$cilBaseUrl/educacao',
      'sports': '$cilBaseUrl/desporto',
      'social': '$cilBaseUrl/accao-social',
      'youth': '$cilBaseUrl/juventude',
    };
    return pages[page] ?? cilBaseUrl;
  }

  /// Social media links
  static const Map<String, String> socialLinks = {
    'facebook': 'https://www.facebook.com/cilisboa',
    'instagram': 'https://www.instagram.com/comunidade_islamica_lisboa',
    'youtube': 'https://www.youtube.com/@cilisboa',
    'twitter': 'https://twitter.com/cilisboa',
  };

  /// Open social media
  static Future<void> openSocialMedia(String platform) async {
    final url = socialLinks[platform];
    if (url != null) {
      await openInBrowser(url);
    }
  }
}
