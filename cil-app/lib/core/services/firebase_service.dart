import 'package:flutter/foundation.dart';

/// Firebase Service - Stub implementation (Firebase removed to reduce dependencies)
/// The app uses the Wix website backend via RSS feeds and WebView
class FirebaseService {
  static bool _initialized = false;

  /// Initialize (no-op without Firebase)
  static Future<void> initialize() async {
    _initialized = true;
    debugPrint('App initialized (using Wix backend)');
  }

  /// Check if service is available
  static bool get isAvailable => _initialized;

  /// Check if user is logged in (always false without Firebase)
  static bool get isLoggedIn => false;
}

/// Firestore Collections (kept for reference if Firebase is added later)
class FirestoreCollections {
  static const String users = 'users';
  static const String events = 'events';
  static const String news = 'news';
  static const String donations = 'donations';
  static const String membershipRequests = 'membership_requests';
  static const String weddingBookings = 'wedding_bookings';
  static const String contactMessages = 'contact_messages';
  static const String prayerTimes = 'prayer_times';
}
