/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'CIL - Comunidade Islâmica de Lisboa';
  static const String appVersion = '1.0.0';

  // API Endpoints
  static const String baseUrl = 'https://www.comunidadeislamica.pt';
  static const String aladhanApiUrl = 'https://api.aladhan.com/v1';

  // Location - Lisbon Central Mosque
  static const double mosqueLat = 38.7436;
  static const double mosqueLng = -9.1586;
  static const String mosqueAddress = 'Rua da Mesquita, Praça de Espanha, Lisboa';
  static const String mosqueCity = 'Lisbon';
  static const String mosqueCountry = 'Portugal';

  // Prayer Calculation Method
  // 3 = Muslim World League (commonly used in Europe)
  static const int prayerCalculationMethod = 3;

  // Website URLs
  static const String websiteUrl = 'https://www.comunidadeislamica.pt';
  static const String wixSiteId = 'f6dd4b75-923b-46a3-95da-9bf7e9b0295b';

  // Contact Info
  static const String email = 'secretaria@cil.org.pt';
  static const String phone = '+351 21 387 4742';

  // Social Media (from website analysis)
  static const String facebookUrl = 'https://facebook.com/comunidadeislamica.pt';
  static const String instagramUrl = 'https://instagram.com/comunidadeislamica.pt';
  static const String youtubeUrl = 'https://youtube.com/mesquitacentraldelisboa';

  // Website Page URLs
  static const String newsUrl = '$websiteUrl/noticias';
  static const String eventsUrl = '$websiteUrl/events-1';
  static const String donateUrl = '$websiteUrl/donate';
  static const String membershipUrl = '$websiteUrl/associado';
  static const String weddingUrl = '$websiteUrl/marcação-de-casamento';
  static const String contactUrl = '$websiteUrl/contactos';
  static const String socialActionUrl = '$websiteUrl/acao-social';
  static const String sportsUrl = '$websiteUrl/pavilhao-desportivo';
  static const String hallReservationUrl = '$websiteUrl/reserva-de-salão';
  static const String aboutIslamUrl = '$websiteUrl/sobre-o-islão';
  static const String privacyPolicyUrl = '$websiteUrl/política-de-privacidade';
  static const String termsUrl = '$websiteUrl/termos-e-condiçoes';

  // RSS Feed
  static const String rssFeedUrl = '$websiteUrl/blog-feed.xml';

  // Storage Keys
  static const String languageKey = 'language';
  static const String themeKey = 'theme';
  static const String notificationsKey = 'notifications';
  static const String prayerNotificationsKey = 'prayer_notifications';
  static const String userTokenKey = 'user_token';
  static const String onboardingCompleteKey = 'onboarding_complete';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Cache Duration
  static const Duration prayerTimesCacheDuration = Duration(hours: 12);
  static const Duration newsCacheDuration = Duration(hours: 1);
  static const Duration eventsCacheDuration = Duration(hours: 1);
}

/// Prayer names in different languages
class PrayerNames {
  static const Map<String, Map<String, String>> names = {
    'fajr': {'pt': 'Fajr (Alvorada)', 'en': 'Fajr (Dawn)', 'fr': 'Fajr (Aube)'},
    'sunrise': {'pt': 'Nascer do Sol', 'en': 'Sunrise', 'fr': 'Lever du Soleil'},
    'dhuhr': {'pt': 'Dhuhr (Meio-dia)', 'en': 'Dhuhr (Noon)', 'fr': 'Dhuhr (Midi)'},
    'asr': {'pt': 'Asr (Tarde)', 'en': 'Asr (Afternoon)', 'fr': 'Asr (Après-midi)'},
    'maghrib': {'pt': 'Maghrib (Pôr do Sol)', 'en': 'Maghrib (Sunset)', 'fr': 'Maghrib (Coucher)'},
    'isha': {'pt': 'Isha (Noite)', 'en': 'Isha (Night)', 'fr': 'Isha (Nuit)'},
  };
}

/// Islamic months
class IslamicMonths {
  static const List<Map<String, String>> months = [
    {'ar': 'محرم', 'pt': 'Muharram', 'en': 'Muharram', 'fr': 'Mouharram'},
    {'ar': 'صفر', 'pt': 'Safar', 'en': 'Safar', 'fr': 'Safar'},
    {'ar': 'ربيع الأول', 'pt': 'Rabi al-Awwal', 'en': 'Rabi al-Awwal', 'fr': 'Rabi al-Awwal'},
    {'ar': 'ربيع الثاني', 'pt': 'Rabi al-Thani', 'en': 'Rabi al-Thani', 'fr': 'Rabi al-Thani'},
    {'ar': 'جمادى الأولى', 'pt': 'Jumada al-Awwal', 'en': 'Jumada al-Awwal', 'fr': 'Joumada al-Awwal'},
    {'ar': 'جمادى الآخرة', 'pt': 'Jumada al-Thani', 'en': 'Jumada al-Thani', 'fr': 'Joumada al-Thani'},
    {'ar': 'رجب', 'pt': 'Rajab', 'en': 'Rajab', 'fr': 'Rajab'},
    {'ar': 'شعبان', 'pt': 'Shaban', 'en': 'Shaban', 'fr': 'Chaabane'},
    {'ar': 'رمضان', 'pt': 'Ramadão', 'en': 'Ramadan', 'fr': 'Ramadan'},
    {'ar': 'شوال', 'pt': 'Shawwal', 'en': 'Shawwal', 'fr': 'Chawwal'},
    {'ar': 'ذو القعدة', 'pt': 'Dhu al-Qadah', 'en': 'Dhu al-Qadah', 'fr': 'Dhoul Qiida'},
    {'ar': 'ذو الحجة', 'pt': 'Dhu al-Hijjah', 'en': 'Dhu al-Hijjah', 'fr': 'Dhoul Hijja'},
  ];
}
