import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../models/invoice.dart';
import '../models/client.dart';

/// Dashboard Screen - Shows business metrics and statistics
class DashboardScreen extends StatelessWidget {
  final List<Invoice> invoices;
  final List<Client> clients;

  const DashboardScreen({
    super.key,
    required this.invoices,
    required this.clients,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message with owner name
            Text(
              'Welcome, ${AppConstants.ownerName}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppConstants.companyName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Track your invoices, clients, and products',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 24),

            // Revenue metrics
            const Text(
              'Revenue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Total Revenue',
                    value: '${AppConstants.currency}0.00',
                    icon: Icons.account_balance_wallet,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'This Month',
                    value: '${AppConstants.currency}0.00',
                    icon: Icons.calendar_today,
                    color: AppColors.successGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Outstanding',
                    value: '${AppConstants.currency}0.00',
                    icon: Icons.pending_actions,
                    color: AppColors.warningOrange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Average Invoice',
                    value: '${AppConstants.currency}0.00',
                    icon: Icons.receipt,
                    color: AppColors.infoPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Business metrics
            const Text(
              'Business Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _CountCard(
                    title: 'Total Clients',
                    count: 0,
                    icon: Icons.people,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CountCard(
                    title: 'Total Products',
                    count: 0,
                    icon: Icons.inventory_2,
                    color: AppColors.successGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _CountCard(
                    title: 'Total Invoices',
                    count: 0,
                    icon: Icons.receipt_long,
                    color: AppColors.infoPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CountCard(
                    title: 'Paid Invoices',
                    count: 0,
                    icon: Icons.check_circle,
                    color: AppColors.statusPaid,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 12),

            _QuickActionCard(
              title: 'Create Invoice',
              subtitle: 'Create a new invoice for your client',
              icon: Icons.add_card,
              color: AppColors.primaryBlue,
              onTap: () {
                // TODO: Navigate to create invoice
              },
            ),
            const SizedBox(height: 12),

            _QuickActionCard(
              title: 'Add Client',
              subtitle: 'Add a new client to your list',
              icon: Icons.person_add,
              color: AppColors.successGreen,
              onTap: () {
                // TODO: Navigate to add client
              },
            ),
            const SizedBox(height: 12),

            _QuickActionCard(
              title: 'Add Product',
              subtitle: 'Add a new product or service',
              icon: Icons.add_box,
              color: AppColors.warningOrange,
              onTap: () {
                // TODO: Navigate to add product
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Metric Card Widget - Shows financial metrics
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Count Card Widget - Shows count metrics
class _CountCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _CountCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick Action Card Widget - Shows action buttons
class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textGrey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
