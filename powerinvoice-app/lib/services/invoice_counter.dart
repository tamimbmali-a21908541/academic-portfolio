import 'package:shared_preferences/shared_preferences.dart';

/// Invoice Counter Service - Manages auto-incrementing invoice numbers
class InvoiceCounter {
  static const String _counterKey = 'invoice_counter';

  /// Get the next invoice number and increment the counter
  static Future<String> getNextInvoiceNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCounter = prefs.getInt(_counterKey) ?? 0;
    final nextCounter = currentCounter + 1;

    // Save the incremented counter
    await prefs.setInt(_counterKey, nextCounter);

    // Format as INV-0001, INV-0002, etc.
    return 'INV-${nextCounter.toString().padLeft(4, '0')}';
  }

  /// Get the current counter value without incrementing
  static Future<int> getCurrentCounter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_counterKey) ?? 0;
  }

  /// Reset counter to 0 (for testing or reset purposes)
  static Future<void> resetCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_counterKey, 0);
  }

  /// Set counter to specific value
  static Future<void> setCounter(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_counterKey, value);
  }
}
