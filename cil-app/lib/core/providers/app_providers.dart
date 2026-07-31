import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../services/prayer_times_service.dart';
import '../services/news_service.dart';
import '../services/events_service.dart';
import '../services/auth_service.dart';

/// Locale Provider for managing app language
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('pt', 'PT');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(AppConstants.languageKey) ?? 'pt';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> setLocale(String languageCode) async {
    _locale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.languageKey, languageCode);
    notifyListeners();
  }
}

/// Theme Provider for managing app theme
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(AppConstants.themeKey) ?? 'light';
    _themeMode = themeName == 'dark' ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.themeKey, mode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    await setThemeMode(_themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }
}

/// Notification Settings Provider
class NotificationProvider extends ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _prayerNotificationsEnabled = true;
  bool _newsNotificationsEnabled = true;
  bool _eventNotificationsEnabled = true;

  // Individual prayer notifications
  bool _fajrNotification = true;
  bool _dhuhrNotification = true;
  bool _asrNotification = true;
  bool _maghribNotification = true;
  bool _ishaNotification = true;

  // Minutes before prayer for notification
  int _notificationMinutesBefore = 15;

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get prayerNotificationsEnabled => _prayerNotificationsEnabled;
  bool get newsNotificationsEnabled => _newsNotificationsEnabled;
  bool get eventNotificationsEnabled => _eventNotificationsEnabled;
  bool get fajrNotification => _fajrNotification;
  bool get dhuhrNotification => _dhuhrNotification;
  bool get asrNotification => _asrNotification;
  bool get maghribNotification => _maghribNotification;
  bool get ishaNotification => _ishaNotification;
  int get notificationMinutesBefore => _notificationMinutesBefore;

  NotificationProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _prayerNotificationsEnabled = prefs.getBool('prayer_notifications') ?? true;
    _newsNotificationsEnabled = prefs.getBool('news_notifications') ?? true;
    _eventNotificationsEnabled = prefs.getBool('event_notifications') ?? true;
    _fajrNotification = prefs.getBool('fajr_notification') ?? true;
    _dhuhrNotification = prefs.getBool('dhuhr_notification') ?? true;
    _asrNotification = prefs.getBool('asr_notification') ?? true;
    _maghribNotification = prefs.getBool('maghrib_notification') ?? true;
    _ishaNotification = prefs.getBool('isha_notification') ?? true;
    _notificationMinutesBefore = prefs.getInt('notification_minutes_before') ?? 15;
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    notifyListeners();
  }

  Future<void> setPrayerNotificationsEnabled(bool value) async {
    _prayerNotificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prayer_notifications', value);
    notifyListeners();
  }

  Future<void> setNotificationMinutesBefore(int minutes) async {
    _notificationMinutesBefore = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_minutes_before', minutes);
    notifyListeners();
  }

  Future<void> setPrayerNotification(String prayer, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    switch (prayer) {
      case 'fajr':
        _fajrNotification = value;
        await prefs.setBool('fajr_notification', value);
        break;
      case 'dhuhr':
        _dhuhrNotification = value;
        await prefs.setBool('dhuhr_notification', value);
        break;
      case 'asr':
        _asrNotification = value;
        await prefs.setBool('asr_notification', value);
        break;
      case 'maghrib':
        _maghribNotification = value;
        await prefs.setBool('maghrib_notification', value);
        break;
      case 'isha':
        _ishaNotification = value;
        await prefs.setBool('isha_notification', value);
        break;
    }
    notifyListeners();
  }
}

/// Prayer Times Provider
class PrayerTimesProvider extends ChangeNotifier {
  final PrayerTimesService _service = PrayerTimesService();

  PrayerTimesData? _todayPrayers;
  List<PrayerTimesData>? _monthPrayers;
  bool _isLoading = false;
  String? _error;

  PrayerTimesData? get todayPrayers => _todayPrayers;
  List<PrayerTimesData>? get monthPrayers => _monthPrayers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTodayPrayers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _todayPrayers = await _service.getTodayPrayerTimes();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMonthPrayers(int month, int year) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _monthPrayers = await _service.getMonthPrayerTimes(month, year);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}

/// News Provider
class NewsProvider extends ChangeNotifier {
  final NewsService _service = NewsService();

  List<NewsItem>? _news;
  bool _isLoading = false;
  String? _error;

  List<NewsItem>? get news => _news;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchNews() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _news = await _service.getNews();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}

/// Events Provider
class EventsProvider extends ChangeNotifier {
  final EventsService _service = EventsService();

  List<EventItem>? _events;
  List<EventItem>? _upcomingEvents;
  bool _isLoading = false;
  String? _error;

  List<EventItem>? get events => _events;
  List<EventItem>? get upcomingEvents => _upcomingEvents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await _service.getEvents();
      _upcomingEvents = _events?.where((e) => e.date.isAfter(DateTime.now())).toList();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}

/// Auth Provider
class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _service.getCurrentUser();
      _isAuthenticated = _user != null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _service.login(email, password);
      _isAuthenticated = _user != null;
      _isLoading = false;
      notifyListeners();
      return _isAuthenticated;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _service.register(name, email, password);
      _isAuthenticated = _user != null;
      _isLoading = false;
      notifyListeners();
      return _isAuthenticated;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _service.logout();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}

/// All App Providers
class AppProviders {
  static List<SingleChildWidget> get providers => [
    ChangeNotifierProvider(create: (_) => LocaleProvider()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => NotificationProvider()),
    ChangeNotifierProvider(create: (_) => PrayerTimesProvider()),
    ChangeNotifierProvider(create: (_) => NewsProvider()),
    ChangeNotifierProvider(create: (_) => EventsProvider()),
    ChangeNotifierProvider(create: (_) => AuthProvider()),
  ];
}
