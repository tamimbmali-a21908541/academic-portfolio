import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/navigation_service.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.access_time,
        label: 'Horários',
        color: AppColors.fajrColor,
        onTap: () => context.go(AppRoutes.prayerTimes),
      ),
      _QuickAction(
        icon: Icons.calendar_month,
        label: 'Calendário',
        color: AppColors.dhuhrColor,
        onTap: () => context.push(AppRoutes.calendar),
      ),
      _QuickAction(
        icon: Icons.explore,
        label: 'Qibla',
        color: AppColors.asrColor,
        onTap: () {
          // Show Qibla compass
          _showQiblaDialog(context);
        },
      ),
      _QuickAction(
        icon: Icons.volunteer_activism,
        label: 'Doação',
        color: AppColors.success,
        onTap: () => context.push(AppRoutes.donation),
      ),
      _QuickAction(
        icon: Icons.favorite,
        label: 'Associado',
        color: AppColors.error,
        onTap: () => context.push(AppRoutes.membership),
      ),
      _QuickAction(
        icon: Icons.menu_book,
        label: 'Sobre o Islão',
        color: AppColors.accent,
        onTap: () => context.push(AppRoutes.aboutIslam),
      ),
      _QuickAction(
        icon: Icons.celebration,
        label: 'Casamento',
        color: AppColors.secondary,
        onTap: () => context.push(AppRoutes.wedding),
      ),
      _QuickAction(
        icon: Icons.phone,
        label: 'Contactos',
        color: AppColors.info,
        onTap: () => context.push(AppRoutes.contact),
      ),
    ];

    return SizedBox(
      height: 220,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return _buildActionItem(context, action);
        },
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, _QuickAction action) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: action.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: action.color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                action.label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : action.color,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQiblaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.explore, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Direção da Qibla'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 3),
              ),
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  // Compass rose
                  Icon(
                    Icons.navigation,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  Positioned(
                    top: 8,
                    child: Text(
                      'N',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Direção: 117.8° SE',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'A direção da Qibla a partir de Lisboa é aproximadamente 117.8° Sudeste.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
