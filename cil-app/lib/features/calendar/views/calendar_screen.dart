import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  // Sample Islamic events
  final List<IslamicEvent> _islamicEvents = [
    IslamicEvent(name: 'Ano Novo Islâmico', hijriMonth: 1, hijriDay: 1),
    IslamicEvent(name: 'Ashura', hijriMonth: 1, hijriDay: 10),
    IslamicEvent(name: 'Mawlid (Nascimento do Profeta)', hijriMonth: 3, hijriDay: 12),
    IslamicEvent(name: 'Início do Ramadão', hijriMonth: 9, hijriDay: 1),
    IslamicEvent(name: 'Laylat al-Qadr', hijriMonth: 9, hijriDay: 27),
    IslamicEvent(name: 'Eid al-Fitr', hijriMonth: 10, hijriDay: 1),
    IslamicEvent(name: 'Dia de Arafat', hijriMonth: 12, hijriDay: 9),
    IslamicEvent(name: 'Eid al-Adha', hijriMonth: 12, hijriDay: 10),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário Islâmico'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Converter Section
            _buildDateConverterCard(context),
            const SizedBox(height: 24),

            // Islamic Months
            Text(
              'Meses Islâmicos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildIslamicMonthsGrid(context),
            const SizedBox(height: 24),

            // Important Dates
            Text(
              'Datas Importantes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildImportantDates(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDateConverterCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Data de Hoje',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Gregoriano',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('dd').format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          DateFormat('MMMM yyyy', 'pt_PT').format(_selectedDate),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.swap_horiz, color: AppColors.textSecondaryLight),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'Hijri',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '27',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                        Text(
                          'Jumada II 1446',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              icon: const Icon(Icons.edit_calendar),
              label: const Text('Selecionar Data'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIslamicMonthsGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2,
      ),
      itemCount: IslamicMonths.months.length,
      itemBuilder: (context, index) {
        final month = IslamicMonths.months[index];
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                month['ar'] ?? '',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                month['pt'] ?? '',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImportantDates(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _islamicEvents.length,
      itemBuilder: (context, index) {
        final event = _islamicEvents[index];
        final monthName = IslamicMonths.months[event.hijriMonth - 1]['pt'];

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${event.hijriDay}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    monthName?.substring(0, 3) ?? '',
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            title: Text(event.name),
            subtitle: Text('$monthName ${event.hijriDay}'),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondaryLight),
          ),
        );
      },
    );
  }
}

class IslamicEvent {
  final String name;
  final int hijriMonth;
  final int hijriDay;

  IslamicEvent({
    required this.name,
    required this.hijriMonth,
    required this.hijriDay,
  });
}
