import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Definições'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            _buildSectionHeader(context, 'Aparência'),
            const SizedBox(height: 8),
            _buildThemeSelector(context),
            const SizedBox(height: 24),

            // Language Section
            _buildSectionHeader(context, 'Idioma'),
            const SizedBox(height: 8),
            _buildLanguageSelector(context),
            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionHeader(context, 'Notificações'),
            const SizedBox(height: 8),
            _buildNotificationsSettings(context),
            const SizedBox(height: 24),

            // Prayer Notifications
            _buildSectionHeader(context, 'Notificações de Oração'),
            const SizedBox(height: 8),
            _buildPrayerNotifications(context),
            const SizedBox(height: 24),

            // About Section
            _buildSectionHeader(context, 'Sobre'),
            const SizedBox(height: 8),
            _buildAboutSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('Modo Claro'),
                secondary: const Icon(Icons.light_mode),
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (value) => themeProvider.setThemeMode(value!),
              ),
              const Divider(height: 1),
              RadioListTile<ThemeMode>(
                title: const Text('Modo Escuro'),
                secondary: const Icon(Icons.dark_mode),
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (value) => themeProvider.setThemeMode(value!),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              RadioListTile<String>(
                title: const Text('Português'),
                secondary: const Text('🇵🇹', style: TextStyle(fontSize: 24)),
                value: 'pt',
                groupValue: localeProvider.locale.languageCode,
                onChanged: (value) => localeProvider.setLocale(value!),
              ),
              const Divider(height: 1),
              RadioListTile<String>(
                title: const Text('English'),
                secondary: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                value: 'en',
                groupValue: localeProvider.locale.languageCode,
                onChanged: (value) => localeProvider.setLocale(value!),
              ),
              const Divider(height: 1),
              RadioListTile<String>(
                title: const Text('Français'),
                secondary: const Text('🇫🇷', style: TextStyle(fontSize: 24)),
                value: 'fr',
                groupValue: localeProvider.locale.languageCode,
                onChanged: (value) => localeProvider.setLocale(value!),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationsSettings(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Notificações'),
                subtitle: const Text('Ativar todas as notificações'),
                secondary: const Icon(Icons.notifications),
                value: notificationProvider.notificationsEnabled,
                onChanged: (value) => notificationProvider.setNotificationsEnabled(value),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Notificações de Oração'),
                subtitle: const Text('Receber alertas antes das orações'),
                secondary: const Icon(Icons.access_time),
                value: notificationProvider.prayerNotificationsEnabled,
                onChanged: notificationProvider.notificationsEnabled
                    ? (value) => notificationProvider.setPrayerNotificationsEnabled(value)
                    : null,
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Tempo antes da oração'),
                subtitle: Text('${notificationProvider.notificationMinutesBefore} minutos'),
                leading: const Icon(Icons.timer),
                trailing: DropdownButton<int>(
                  value: notificationProvider.notificationMinutesBefore,
                  items: [5, 10, 15, 20, 30].map((minutes) {
                    return DropdownMenuItem(
                      value: minutes,
                      child: Text('$minutes min'),
                    );
                  }).toList(),
                  onChanged: notificationProvider.prayerNotificationsEnabled
                      ? (value) => notificationProvider.setNotificationMinutesBefore(value!)
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrayerNotifications(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        final isEnabled = notificationProvider.prayerNotificationsEnabled;

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              _buildPrayerToggle('Fajr', notificationProvider.fajrNotification, isEnabled,
                  (v) => notificationProvider.setPrayerNotification('fajr', v)),
              const Divider(height: 1),
              _buildPrayerToggle('Dhuhr', notificationProvider.dhuhrNotification, isEnabled,
                  (v) => notificationProvider.setPrayerNotification('dhuhr', v)),
              const Divider(height: 1),
              _buildPrayerToggle('Asr', notificationProvider.asrNotification, isEnabled,
                  (v) => notificationProvider.setPrayerNotification('asr', v)),
              const Divider(height: 1),
              _buildPrayerToggle('Maghrib', notificationProvider.maghribNotification, isEnabled,
                  (v) => notificationProvider.setPrayerNotification('maghrib', v)),
              const Divider(height: 1),
              _buildPrayerToggle('Isha', notificationProvider.ishaNotification, isEnabled,
                  (v) => notificationProvider.setPrayerNotification('isha', v)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrayerToggle(String prayer, bool value, bool isEnabled, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(prayer),
      value: value,
      onChanged: isEnabled ? onChanged : null,
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Versão'),
            trailing: Text('1.0.0'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Termos e Condições'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to terms
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Política de Privacidade'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to privacy
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Licenças de Software'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'CIL App',
                applicationVersion: '1.0.0',
              );
            },
          ),
        ],
      ),
    );
  }
}
