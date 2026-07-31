import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/prayer_times_service.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<PrayerTimesProvider>().fetchTodayPrayers();
    context.read<PrayerTimesProvider>().fetchMonthPrayers(
      _selectedDate.month,
      _selectedDate.year,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horários de Oração'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Hoje'),
            Tab(text: 'Mensal'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayTab(),
          _buildMonthlyTab(),
        ],
      ),
    );
  }

  Widget _buildTodayTab() {
    return Consumer<PrayerTimesProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.todayPrayers == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null || provider.todayPrayers == null) {
          return _buildErrorState(provider.error ?? 'Erro ao carregar');
        }

        final prayers = provider.todayPrayers!;
        final now = DateTime.now();

        return RefreshIndicator(
          onRefresh: () async {
            context.read<PrayerTimesProvider>().fetchTodayPrayers();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Card
                _buildDateCard(prayers),
                const SizedBox(height: 24),

                // Prayer Times List
                _buildPrayerTimeItem('Fajr', prayers.fajr, AppColors.fajrColor, Icons.nights_stay, prayers.getCurrentPrayer(now) == 'fajr'),
                _buildPrayerTimeItem('Nascer do Sol', prayers.sunrise, AppColors.sunriseColor, Icons.wb_sunny, false, isAdhan: false),
                _buildPrayerTimeItem('Dhuhr', prayers.dhuhr, AppColors.dhuhrColor, Icons.wb_sunny, prayers.getCurrentPrayer(now) == 'dhuhr'),
                _buildPrayerTimeItem('Asr', prayers.asr, AppColors.asrColor, Icons.wb_twilight, prayers.getCurrentPrayer(now) == 'asr'),
                _buildPrayerTimeItem('Maghrib', prayers.maghrib, AppColors.maghribColor, Icons.nights_stay, prayers.getCurrentPrayer(now) == 'maghrib'),
                _buildPrayerTimeItem('Isha', prayers.isha, AppColors.ishaColor, Icons.dark_mode, prayers.getCurrentPrayer(now) == 'isha'),

                const SizedBox(height: 24),

                // Info Card
                _buildInfoCard(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthlyTab() {
    return Consumer<PrayerTimesProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            // Month Selector
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).cardColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
                      });
                      context.read<PrayerTimesProvider>().fetchMonthPrayers(
                        _selectedDate.month,
                        _selectedDate.year,
                      );
                    },
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text(
                    DateFormat('MMMM yyyy', 'pt_PT').format(_selectedDate),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
                      });
                      context.read<PrayerTimesProvider>().fetchMonthPrayers(
                        _selectedDate.month,
                        _selectedDate.year,
                      );
                    },
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),

            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: AppColors.primary,
              child: const Row(
                children: [
                  SizedBox(width: 50, child: Text('Dia', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                  Expanded(child: Center(child: Text('Fajr', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)))),
                  Expanded(child: Center(child: Text('Dhuhr', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)))),
                  Expanded(child: Center(child: Text('Asr', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)))),
                  Expanded(child: Center(child: Text('Magh', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)))),
                  Expanded(child: Center(child: Text('Isha', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)))),
                ],
              ),
            ),

            // Monthly Data
            Expanded(
              child: provider.isLoading && provider.monthPrayers == null
                  ? const Center(child: CircularProgressIndicator())
                  : provider.monthPrayers == null
                      ? const Center(child: Text('Sem dados'))
                      : ListView.builder(
                          itemCount: provider.monthPrayers!.length,
                          itemBuilder: (context, index) {
                            final day = provider.monthPrayers![index];
                            final isToday = day.date.day == DateTime.now().day &&
                                day.date.month == DateTime.now().month &&
                                day.date.year == DateTime.now().year;

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isToday
                                    ? AppColors.primary.withOpacity(0.1)
                                    : index % 2 == 0
                                        ? Colors.transparent
                                        : Colors.grey.withOpacity(0.05),
                                border: isToday
                                    ? Border.all(color: AppColors.primary, width: 2)
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 50,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          day.date.day.toString(),
                                          style: TextStyle(
                                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                            color: isToday ? AppColors.primary : null,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('EEE', 'pt_PT').format(day.date),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(child: Center(child: Text(day.fajr, style: const TextStyle(fontSize: 12)))),
                                  Expanded(child: Center(child: Text(day.dhuhr, style: const TextStyle(fontSize: 12)))),
                                  Expanded(child: Center(child: Text(day.asr, style: const TextStyle(fontSize: 12)))),
                                  Expanded(child: Center(child: Text(day.maghrib, style: const TextStyle(fontSize: 12)))),
                                  Expanded(child: Center(child: Text(day.isha, style: const TextStyle(fontSize: 12)))),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateCard(PrayerTimesData prayers) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'pt_PT');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            dateFormat.format(prayers.date),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            prayers.hijriDate,
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, color: Colors.white70, size: 16),
              SizedBox(width: 4),
              Text(
                'Mesquita Central de Lisboa',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeItem(
    String name,
    String time,
    Color color,
    IconData icon,
    bool isActive, {
    bool isAdhan = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppColors.primary : null,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              time,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isActive ? AppColors.primary : color,
              ),
            ),
            if (isAdhan) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: Colors.grey[400],
                  size: 20,
                ),
                onPressed: () {
                  // Toggle notification for this prayer
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.info),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cálculo de Horários',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Método: Muslim World League\nLocalização: Lisboa, Portugal',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          const Text('Erro ao carregar horários'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
