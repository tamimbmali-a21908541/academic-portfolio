import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

/// Prayer Times Data Model
class PrayerTimesData {
  final DateTime date;
  final String hijriDate;
  final String hijriMonth;
  final int hijriYear;
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String? qiblaDirection;

  PrayerTimesData({
    required this.date,
    required this.hijriDate,
    required this.hijriMonth,
    required this.hijriYear,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    this.qiblaDirection,
  });

  factory PrayerTimesData.fromAladhanJson(Map<String, dynamic> json) {
    final timings = json['timings'] as Map<String, dynamic>;
    final date = json['date'] as Map<String, dynamic>;
    final hijri = date['hijri'] as Map<String, dynamic>;
    final gregorian = date['gregorian'] as Map<String, dynamic>;

    return PrayerTimesData(
      date: DateTime.parse(gregorian['date'].toString().split('-').reversed.join('-')),
      hijriDate: '${hijri['day']} ${hijri['month']['en']} ${hijri['year']}',
      hijriMonth: hijri['month']['en'],
      hijriYear: int.parse(hijri['year']),
      fajr: _formatTime(timings['Fajr']),
      sunrise: _formatTime(timings['Sunrise']),
      dhuhr: _formatTime(timings['Dhuhr']),
      asr: _formatTime(timings['Asr']),
      maghrib: _formatTime(timings['Maghrib']),
      isha: _formatTime(timings['Isha']),
    );
  }

  static String _formatTime(String time) {
    // Remove timezone suffix like (WEST) or (WET)
    return time.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();
  }

  /// Get current prayer based on time
  String getCurrentPrayer(DateTime now) {
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    if (currentTime.compareTo(fajr) < 0) return 'isha';
    if (currentTime.compareTo(sunrise) < 0) return 'fajr';
    if (currentTime.compareTo(dhuhr) < 0) return 'sunrise';
    if (currentTime.compareTo(asr) < 0) return 'dhuhr';
    if (currentTime.compareTo(maghrib) < 0) return 'asr';
    if (currentTime.compareTo(isha) < 0) return 'maghrib';
    return 'isha';
  }

  /// Get next prayer and its time
  Map<String, String> getNextPrayer(DateTime now) {
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    if (currentTime.compareTo(fajr) < 0) return {'name': 'fajr', 'time': fajr};
    if (currentTime.compareTo(sunrise) < 0) return {'name': 'sunrise', 'time': sunrise};
    if (currentTime.compareTo(dhuhr) < 0) return {'name': 'dhuhr', 'time': dhuhr};
    if (currentTime.compareTo(asr) < 0) return {'name': 'asr', 'time': asr};
    if (currentTime.compareTo(maghrib) < 0) return {'name': 'maghrib', 'time': maghrib};
    if (currentTime.compareTo(isha) < 0) return {'name': 'isha', 'time': isha};
    return {'name': 'fajr', 'time': fajr}; // Next day's Fajr
  }

  /// Get prayer time by name
  String getPrayerTime(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr': return fajr;
      case 'sunrise': return sunrise;
      case 'dhuhr': return dhuhr;
      case 'asr': return asr;
      case 'maghrib': return maghrib;
      case 'isha': return isha;
      default: return '';
    }
  }

  /// Get all prayers as a map
  Map<String, String> get allPrayers => {
    'fajr': fajr,
    'sunrise': sunrise,
    'dhuhr': dhuhr,
    'asr': asr,
    'maghrib': maghrib,
    'isha': isha,
  };
}

/// Prayer Times Service - Uses Aladhan API
class PrayerTimesService {
  static const String _baseUrl = AppConstants.aladhanApiUrl;
  static const double _latitude = AppConstants.mosqueLat;
  static const double _longitude = AppConstants.mosqueLng;
  static const int _method = AppConstants.prayerCalculationMethod;

  /// Get today's prayer times
  Future<PrayerTimesData> getTodayPrayerTimes() async {
    final now = DateTime.now();
    final url = Uri.parse(
      '$_baseUrl/timings/${now.day}-${now.month}-${now.year}'
      '?latitude=$_latitude'
      '&longitude=$_longitude'
      '&method=$_method'
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200) {
          return PrayerTimesData.fromAladhanJson(data['data']);
        }
      }
      throw Exception('Failed to fetch prayer times');
    } catch (e) {
      throw Exception('Error fetching prayer times: $e');
    }
  }

  /// Get prayer times for a specific date
  Future<PrayerTimesData> getPrayerTimesForDate(DateTime date) async {
    final url = Uri.parse(
      '$_baseUrl/timings/${date.day}-${date.month}-${date.year}'
      '?latitude=$_latitude'
      '&longitude=$_longitude'
      '&method=$_method'
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200) {
          return PrayerTimesData.fromAladhanJson(data['data']);
        }
      }
      throw Exception('Failed to fetch prayer times');
    } catch (e) {
      throw Exception('Error fetching prayer times: $e');
    }
  }

  /// Get prayer times for entire month
  Future<List<PrayerTimesData>> getMonthPrayerTimes(int month, int year) async {
    final url = Uri.parse(
      '$_baseUrl/calendar/$year/$month'
      '?latitude=$_latitude'
      '&longitude=$_longitude'
      '&method=$_method'
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200) {
          final List<dynamic> daysData = data['data'];
          return daysData.map((day) => PrayerTimesData.fromAladhanJson(day)).toList();
        }
      }
      throw Exception('Failed to fetch monthly prayer times');
    } catch (e) {
      throw Exception('Error fetching monthly prayer times: $e');
    }
  }

  /// Get Qibla direction
  Future<double> getQiblaDirection() async {
    final url = Uri.parse('$_baseUrl/qibla/$_latitude/$_longitude');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200) {
          return data['data']['direction'].toDouble();
        }
      }
      throw Exception('Failed to fetch Qibla direction');
    } catch (e) {
      throw Exception('Error fetching Qibla direction: $e');
    }
  }

  /// Get Hijri date for today
  Future<Map<String, dynamic>> getHijriDate() async {
    final now = DateTime.now();
    final url = Uri.parse(
      '$_baseUrl/gToH/${now.day}-${now.month}-${now.year}'
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200) {
          return data['data']['hijri'];
        }
      }
      throw Exception('Failed to fetch Hijri date');
    } catch (e) {
      throw Exception('Error fetching Hijri date: $e');
    }
  }

  /// Get Islamic holidays for a year
  Future<List<Map<String, dynamic>>> getIslamicHolidays(int year) async {
    final url = Uri.parse('$_baseUrl/hijriCalendar/$year');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200) {
          // Extract holidays from calendar data
          final List<Map<String, dynamic>> holidays = [];
          // Process holiday data here
          return holidays;
        }
      }
      throw Exception('Failed to fetch Islamic holidays');
    } catch (e) {
      throw Exception('Error fetching Islamic holidays: $e');
    }
  }
}
