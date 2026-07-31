/// PowerInvoice App Constants
class AppConstants {
  // App Info
  static const String appName = 'PowerInvoice';
  static const String appVersion = '1.0.0';
  static const String developerName = 'Tamim Mohamed Ali';

  // Owner/Business Info
  static const String ownerName = 'Tamim Mohamed Ali';
  static const String companyName = 'TAIBATUNA FINE FOOD';

  // Default Values
  static const String currency = '€';
  static const String defaultLanguage = 'en';

  // Backend Configuration
  static const String defaultBackendUrl = ''; // User enters their backend URL

  // Invoice Settings
  static const String invoicePrefix = 'INV-';
  static const int invoiceNumberPadding = 4; // INV-0001, INV-0002, etc.

  // Pagination
  static const int itemsPerPage = 20;

  // Validation
  static const int minProductPrice = 0;
  static const int maxProductPrice = 999999;
  static const int maxClientNameLength = 100;
  static const int maxProductNameLength = 200;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 8.0;
  static const double buttonBorderRadius = 8.0;
  static const double fabSize = 56.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
