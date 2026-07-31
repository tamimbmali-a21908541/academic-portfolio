import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App Protection Service - Prevents unauthorized use of the app
///
/// Even if the APK is shared, the app requires activation with a unique code
/// that is tied to the device. This makes the APK useless on other devices.
class AppProtection {
  static const String _activationKey = 'app_activated';
  static const String _deviceIdKey = 'device_id';
  static const String _masterKey = 'POWERINVOICE_2024_SECURE'; // Change this for your deployment

  // Test mode flag - set to true in test environment to skip device verification
  static bool _testMode = false;

  /// Enable test mode (used in tests to bypass device ID verification)
  static void enableTestMode() {
    _testMode = true;
  }

  /// Disable test mode
  static void disableTestMode() {
    _testMode = false;
  }

  /// Check if the app is activated on this device
  static Future<bool> isActivated() async {
    final prefs = await SharedPreferences.getInstance();
    final isActivated = prefs.getBool(_activationKey) ?? false;

    if (!isActivated) return false;

    // In test mode, skip device ID verification
    if (_testMode) return true;

    // Verify device ID matches
    final storedDeviceId = prefs.getString(_deviceIdKey);
    final currentDeviceId = await _getDeviceId();

    return storedDeviceId == currentDeviceId;
  }

  /// Activate the app with an activation code
  /// Returns true if activation successful, false otherwise
  static Future<bool> activate(String activationCode) async {
    final deviceId = await _getDeviceId();
    final validCode = _generateActivationCode(deviceId);

    if (activationCode.toUpperCase().trim() == validCode) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_activationKey, true);
      await prefs.setString(_deviceIdKey, deviceId);
      return true;
    }

    return false;
  }

  /// Deactivate the app (useful for testing or uninstalling)
  static Future<void> deactivate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activationKey);
    await prefs.remove(_deviceIdKey);
  }

  /// Get the device's unique identifier
  static Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      final androidInfo = await deviceInfo.androidInfo;
      // Use Android ID as device identifier
      return androidInfo.id;
    } catch (e) {
      // Fallback for test environment or when device info is unavailable
      // In tests, we'll use the stored device_id from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_deviceIdKey) ?? 'TEST_DEVICE';
    }
  }

  /// Generate activation code for this device
  /// You can call this to generate codes for your clients
  static Future<String> getDeviceActivationCode() async {
    final deviceId = await _getDeviceId();
    return _generateActivationCode(deviceId);
  }

  /// Generate activation code based on device ID
  static String _generateActivationCode(String deviceId) {
    // Create a unique code by hashing device ID + master key
    final combined = '$deviceId$_masterKey';
    final bytes = utf8.encode(combined);
    final hash = sha256.convert(bytes);

    // Take first 8 characters of hash and format as XXXX-XXXX
    final code = hash.toString().substring(0, 8).toUpperCase();
    return '${code.substring(0, 4)}-${code.substring(4, 8)}';
  }

  /// Get device information for display
  static Future<Map<String, String>> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        'Device ID': androidInfo.id,
        'Brand': androidInfo.brand,
        'Model': androidInfo.model,
        'Android Version': androidInfo.version.release,
        'Manufacturer': androidInfo.manufacturer,
      };
    } catch (e) {
      return {
        'Error': 'Could not retrieve device info',
      };
    }
  }
}
