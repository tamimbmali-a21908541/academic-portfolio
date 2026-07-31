import 'package:flutter/material.dart';

/// App Localizations
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('pt', 'PT'),
    Locale('en', 'US'),
    Locale('fr', 'FR'),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'pt': _ptTranslations,
    'en': _enTranslations,
    'fr': _frTranslations,
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['pt']?[key] ??
        key;
  }

  // Common
  String get appName => get('app_name');
  String get loading => get('loading');
  String get error => get('error');
  String get retry => get('retry');
  String get cancel => get('cancel');
  String get confirm => get('confirm');
  String get save => get('save');
  String get delete => get('delete');
  String get edit => get('edit');
  String get close => get('close');
  String get search => get('search');
  String get seeAll => get('see_all');
  String get back => get('back');

  // Navigation
  String get home => get('home');
  String get prayerTimes => get('prayer_times');
  String get news => get('news');
  String get events => get('events');
  String get profile => get('profile');
  String get settings => get('settings');
  String get about => get('about');
  String get aboutIslam => get('about_islam');
  String get calendar => get('calendar');
  String get contact => get('contact');
  String get donation => get('donation');
  String get membership => get('membership');
  String get wedding => get('wedding');

  // Prayer Times
  String get fajr => get('fajr');
  String get sunrise => get('sunrise');
  String get dhuhr => get('dhuhr');
  String get asr => get('asr');
  String get maghrib => get('maghrib');
  String get isha => get('isha');
  String get nextPrayer => get('next_prayer');
  String get timeRemaining => get('time_remaining');
  String get todayPrayerTimes => get('today_prayer_times');
  String get monthlyPrayerTimes => get('monthly_prayer_times');
  String get qiblaDirection => get('qibla_direction');

  // Auth
  String get login => get('login');
  String get logout => get('logout');
  String get register => get('register');
  String get email => get('email');
  String get password => get('password');
  String get confirmPassword => get('confirm_password');
  String get name => get('name');
  String get phone => get('phone');
  String get forgotPassword => get('forgot_password');
  String get dontHaveAccount => get('dont_have_account');
  String get alreadyHaveAccount => get('already_have_account');

  // Profile
  String get myProfile => get('my_profile');
  String get myEvents => get('my_events');
  String get myDonations => get('my_donations');
  String get notifications => get('notifications');
  String get language => get('language');
  String get theme => get('theme');
  String get darkMode => get('dark_mode');
  String get lightMode => get('light_mode');

  // Mosque Info
  String get mosqueName => get('mosque_name');
  String get mosqueAddress => get('mosque_address');
  String get mosquePhone => get('mosque_phone');
  String get mosqueEmail => get('mosque_email');
  String get openingHours => get('opening_hours');
  String get facilities => get('facilities');

  // Donation
  String get donateNow => get('donate_now');
  String get donationAmount => get('donation_amount');
  String get donationPurpose => get('donation_purpose');
  String get generalDonation => get('general_donation');
  String get zakat => get('zakat');
  String get sadaqah => get('sadaqah');
  String get buildingFund => get('building_fund');

  // Membership
  String get becomeMember => get('become_member');
  String get memberBenefits => get('member_benefits');
  String get membershipFee => get('membership_fee');
  String get renewMembership => get('renew_membership');

  // Wedding
  String get bookWedding => get('book_wedding');
  String get weddingDate => get('wedding_date');
  String get weddingInfo => get('wedding_info');

  // Messages
  String get welcomeMessage => get('welcome_message');
  String get noDataAvailable => get('no_data_available');
  String get noNewsAvailable => get('no_news_available');
  String get noEventsAvailable => get('no_events_available');
  String get loadingPrayerTimes => get('loading_prayer_times');
  String get errorLoadingData => get('error_loading_data');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['pt', 'en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Portuguese translations
const Map<String, String> _ptTranslations = {
  'app_name': 'CIL - Comunidade Islâmica de Lisboa',
  'loading': 'A carregar...',
  'error': 'Erro',
  'retry': 'Tentar novamente',
  'cancel': 'Cancelar',
  'confirm': 'Confirmar',
  'save': 'Guardar',
  'delete': 'Eliminar',
  'edit': 'Editar',
  'close': 'Fechar',
  'search': 'Pesquisar',
  'see_all': 'Ver todos',
  'back': 'Voltar',

  // Navigation
  'home': 'Início',
  'prayer_times': 'Horários',
  'news': 'Notícias',
  'events': 'Eventos',
  'profile': 'Perfil',
  'settings': 'Definições',
  'about': 'Sobre Nós',
  'about_islam': 'Sobre o Islão',
  'calendar': 'Calendário',
  'contact': 'Contactos',
  'donation': 'Doação',
  'membership': 'Associado',
  'wedding': 'Casamento',

  // Prayer Times
  'fajr': 'Fajr (Alvorada)',
  'sunrise': 'Nascer do Sol',
  'dhuhr': 'Dhuhr (Meio-dia)',
  'asr': 'Asr (Tarde)',
  'maghrib': 'Maghrib (Pôr do Sol)',
  'isha': 'Isha (Noite)',
  'next_prayer': 'Próxima Oração',
  'time_remaining': 'Tempo restante',
  'today_prayer_times': 'Horários de Hoje',
  'monthly_prayer_times': 'Horários Mensais',
  'qibla_direction': 'Direção da Qibla',

  // Auth
  'login': 'Entrar',
  'logout': 'Sair',
  'register': 'Registar',
  'email': 'Email',
  'password': 'Palavra-passe',
  'confirm_password': 'Confirmar palavra-passe',
  'name': 'Nome',
  'phone': 'Telefone',
  'forgot_password': 'Esqueceu a palavra-passe?',
  'dont_have_account': 'Não tem conta? Registe-se',
  'already_have_account': 'Já tem conta? Entre',

  // Profile
  'my_profile': 'O Meu Perfil',
  'my_events': 'Os Meus Eventos',
  'my_donations': 'As Minhas Doações',
  'notifications': 'Notificações',
  'language': 'Idioma',
  'theme': 'Tema',
  'dark_mode': 'Modo Escuro',
  'light_mode': 'Modo Claro',

  // Mosque Info
  'mosque_name': 'Mesquita Central de Lisboa',
  'mosque_address': 'Rua da Mesquita, Praça de Espanha, Lisboa',
  'mosque_phone': '+351 21 386 4800',
  'mosque_email': 'geral@cil.org.pt',
  'opening_hours': 'Horário de Funcionamento',
  'facilities': 'Instalações',

  // Donation
  'donate_now': 'Doar Agora',
  'donation_amount': 'Valor da Doação',
  'donation_purpose': 'Finalidade',
  'general_donation': 'Doação Geral',
  'zakat': 'Zakat',
  'sadaqah': 'Sadaqah',
  'building_fund': 'Fundo de Construção',

  // Membership
  'become_member': 'Tornar-se Associado',
  'member_benefits': 'Benefícios de Associado',
  'membership_fee': 'Quota de Associado',
  'renew_membership': 'Renovar Associação',

  // Wedding
  'book_wedding': 'Marcar Casamento',
  'wedding_date': 'Data do Casamento',
  'wedding_info': 'Informações sobre Casamento',

  // Messages
  'welcome_message': 'Bem-vindo à Comunidade Islâmica de Lisboa',
  'no_data_available': 'Sem dados disponíveis',
  'no_news_available': 'Sem notícias disponíveis',
  'no_events_available': 'Sem eventos disponíveis',
  'loading_prayer_times': 'A carregar horários de oração...',
  'error_loading_data': 'Erro ao carregar dados',
};

// English translations
const Map<String, String> _enTranslations = {
  'app_name': 'CIL - Lisbon Islamic Community',
  'loading': 'Loading...',
  'error': 'Error',
  'retry': 'Retry',
  'cancel': 'Cancel',
  'confirm': 'Confirm',
  'save': 'Save',
  'delete': 'Delete',
  'edit': 'Edit',
  'close': 'Close',
  'search': 'Search',
  'see_all': 'See all',
  'back': 'Back',

  // Navigation
  'home': 'Home',
  'prayer_times': 'Prayer Times',
  'news': 'News',
  'events': 'Events',
  'profile': 'Profile',
  'settings': 'Settings',
  'about': 'About Us',
  'about_islam': 'About Islam',
  'calendar': 'Calendar',
  'contact': 'Contact',
  'donation': 'Donation',
  'membership': 'Membership',
  'wedding': 'Wedding',

  // Prayer Times
  'fajr': 'Fajr (Dawn)',
  'sunrise': 'Sunrise',
  'dhuhr': 'Dhuhr (Noon)',
  'asr': 'Asr (Afternoon)',
  'maghrib': 'Maghrib (Sunset)',
  'isha': 'Isha (Night)',
  'next_prayer': 'Next Prayer',
  'time_remaining': 'Time remaining',
  'today_prayer_times': 'Today\'s Prayer Times',
  'monthly_prayer_times': 'Monthly Prayer Times',
  'qibla_direction': 'Qibla Direction',

  // Auth
  'login': 'Login',
  'logout': 'Logout',
  'register': 'Register',
  'email': 'Email',
  'password': 'Password',
  'confirm_password': 'Confirm password',
  'name': 'Name',
  'phone': 'Phone',
  'forgot_password': 'Forgot password?',
  'dont_have_account': 'Don\'t have an account? Register',
  'already_have_account': 'Already have an account? Login',

  // Profile
  'my_profile': 'My Profile',
  'my_events': 'My Events',
  'my_donations': 'My Donations',
  'notifications': 'Notifications',
  'language': 'Language',
  'theme': 'Theme',
  'dark_mode': 'Dark Mode',
  'light_mode': 'Light Mode',

  // Mosque Info
  'mosque_name': 'Lisbon Central Mosque',
  'mosque_address': 'Rua da Mesquita, Praça de Espanha, Lisbon',
  'mosque_phone': '+351 21 386 4800',
  'mosque_email': 'geral@cil.org.pt',
  'opening_hours': 'Opening Hours',
  'facilities': 'Facilities',

  // Donation
  'donate_now': 'Donate Now',
  'donation_amount': 'Donation Amount',
  'donation_purpose': 'Purpose',
  'general_donation': 'General Donation',
  'zakat': 'Zakat',
  'sadaqah': 'Sadaqah',
  'building_fund': 'Building Fund',

  // Membership
  'become_member': 'Become a Member',
  'member_benefits': 'Member Benefits',
  'membership_fee': 'Membership Fee',
  'renew_membership': 'Renew Membership',

  // Wedding
  'book_wedding': 'Book a Wedding',
  'wedding_date': 'Wedding Date',
  'wedding_info': 'Wedding Information',

  // Messages
  'welcome_message': 'Welcome to the Lisbon Islamic Community',
  'no_data_available': 'No data available',
  'no_news_available': 'No news available',
  'no_events_available': 'No events available',
  'loading_prayer_times': 'Loading prayer times...',
  'error_loading_data': 'Error loading data',
};

// French translations
const Map<String, String> _frTranslations = {
  'app_name': 'CIL - Communauté Islamique de Lisbonne',
  'loading': 'Chargement...',
  'error': 'Erreur',
  'retry': 'Réessayer',
  'cancel': 'Annuler',
  'confirm': 'Confirmer',
  'save': 'Sauvegarder',
  'delete': 'Supprimer',
  'edit': 'Modifier',
  'close': 'Fermer',
  'search': 'Rechercher',
  'see_all': 'Voir tout',
  'back': 'Retour',

  // Navigation
  'home': 'Accueil',
  'prayer_times': 'Horaires',
  'news': 'Actualités',
  'events': 'Événements',
  'profile': 'Profil',
  'settings': 'Paramètres',
  'about': 'À Propos',
  'about_islam': 'Sur l\'Islam',
  'calendar': 'Calendrier',
  'contact': 'Contact',
  'donation': 'Don',
  'membership': 'Adhésion',
  'wedding': 'Mariage',

  // Prayer Times
  'fajr': 'Fajr (Aube)',
  'sunrise': 'Lever du Soleil',
  'dhuhr': 'Dhuhr (Midi)',
  'asr': 'Asr (Après-midi)',
  'maghrib': 'Maghrib (Coucher)',
  'isha': 'Isha (Nuit)',
  'next_prayer': 'Prochaine Prière',
  'time_remaining': 'Temps restant',
  'today_prayer_times': 'Horaires d\'Aujourd\'hui',
  'monthly_prayer_times': 'Horaires Mensuels',
  'qibla_direction': 'Direction de la Qibla',

  // Auth
  'login': 'Connexion',
  'logout': 'Déconnexion',
  'register': 'S\'inscrire',
  'email': 'Email',
  'password': 'Mot de passe',
  'confirm_password': 'Confirmer le mot de passe',
  'name': 'Nom',
  'phone': 'Téléphone',
  'forgot_password': 'Mot de passe oublié?',
  'dont_have_account': 'Pas de compte? Inscrivez-vous',
  'already_have_account': 'Déjà un compte? Connectez-vous',

  // Profile
  'my_profile': 'Mon Profil',
  'my_events': 'Mes Événements',
  'my_donations': 'Mes Dons',
  'notifications': 'Notifications',
  'language': 'Langue',
  'theme': 'Thème',
  'dark_mode': 'Mode Sombre',
  'light_mode': 'Mode Clair',

  // Mosque Info
  'mosque_name': 'Mosquée Centrale de Lisbonne',
  'mosque_address': 'Rua da Mesquita, Praça de Espanha, Lisbonne',
  'mosque_phone': '+351 21 386 4800',
  'mosque_email': 'geral@cil.org.pt',
  'opening_hours': 'Heures d\'Ouverture',
  'facilities': 'Installations',

  // Donation
  'donate_now': 'Faire un Don',
  'donation_amount': 'Montant du Don',
  'donation_purpose': 'Objectif',
  'general_donation': 'Don Général',
  'zakat': 'Zakat',
  'sadaqah': 'Sadaqah',
  'building_fund': 'Fonds de Construction',

  // Membership
  'become_member': 'Devenir Membre',
  'member_benefits': 'Avantages Membres',
  'membership_fee': 'Cotisation',
  'renew_membership': 'Renouveler l\'Adhésion',

  // Wedding
  'book_wedding': 'Réserver un Mariage',
  'wedding_date': 'Date du Mariage',
  'wedding_info': 'Informations sur le Mariage',

  // Messages
  'welcome_message': 'Bienvenue à la Communauté Islamique de Lisbonne',
  'no_data_available': 'Aucune donnée disponible',
  'no_news_available': 'Aucune actualité disponible',
  'no_events_available': 'Aucun événement disponible',
  'loading_prayer_times': 'Chargement des horaires de prière...',
  'error_loading_data': 'Erreur lors du chargement des données',
};
