import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';

class PrayerTimesCard extends StatefulWidget {
  const PrayerTimesCard({super.key});

  @override
  State<PrayerTimesCard> createState() => _PrayerTimesCardState();
}

class _PrayerTimesCardState extends State<PrayerTimesCard> {
  Timer? _timer;
  String _countdown = '';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    final provider = context.read<PrayerTimesProvider>();
    if (provider.todayPrayers == null) return;

    final now = DateTime.now();
    final nextPrayer = provider.todayPrayers!.getNextPrayer(now);
    final nextTime = nextPrayer['time']!;

    final parts = nextTime.split(':');
    if (parts.length != 2) return;

    final nextHour = int.tryParse(parts[0]) ?? 0;
    final nextMinute = int.tryParse(parts[1]) ?? 0;

    var nextDateTime = DateTime(now.year, now.month, now.day, nextHour, nextMinute);

    // If next prayer is tomorrow (Fajr after Isha)
    if (nextDateTime.isBefore(now)) {
      nextDateTime = nextDateTime.add(const Duration(days: 1));
    }

    final difference = nextDateTime.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    setState(() {
      _countdown = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerTimesProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return _buildLoadingCard();
        }

        if (provider.error != null || provider.todayPrayers == null) {
          return _buildErrorCard(provider.error ?? 'Erro ao carregar horários');
        }

        final prayers = provider.todayPrayers!;
        final now = DateTime.now();
        final currentPrayer = prayers.getCurrentPrayer(now);
        final nextPrayer = prayers.getNextPrayer(now);

        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Next Prayer Highlight
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_active,
                          color: Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Próxima Oração',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getPrayerName(nextPrayer['name']!),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nextPrayer['time']!,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _countdown.isNotEmpty ? 'Faltam $_countdown' : 'A calcular...',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // All Prayer Times
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.white.withOpacity(0.15),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPrayerTime('Fajr', prayers.fajr, currentPrayer == 'fajr'),
                    _buildPrayerTime('Dhuhr', prayers.dhuhr, currentPrayer == 'dhuhr'),
                    _buildPrayerTime('Asr', prayers.asr, currentPrayer == 'asr'),
                    _buildPrayerTime('Maghrib', prayers.maghrib, currentPrayer == 'maghrib'),
                    _buildPrayerTime('Isha', prayers.isha, currentPrayer == 'isha'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrayerTime(String name, String time, bool isActive) {
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            color: isActive ? AppColors.secondary : Colors.white70,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            color: isActive ? AppColors.secondary : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        if (isActive)
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Erro ao carregar horários',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                context.read<PrayerTimesProvider>().fetchTodayPrayers();
              },
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  String _getPrayerName(String key) {
    switch (key) {
      case 'fajr': return 'Fajr';
      case 'sunrise': return 'Nascer do Sol';
      case 'dhuhr': return 'Dhuhr';
      case 'asr': return 'Asr';
      case 'maghrib': return 'Maghrib';
      case 'isha': return 'Isha';
      default: return key;
    }
  }
}
