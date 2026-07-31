import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/navigation_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isAuthenticated) {
            return _buildAuthenticatedProfile(context, authProvider);
          } else {
            return _buildGuestProfile(context);
          }
        },
      ),
    );
  }

  Widget _buildAuthenticatedProfile(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.user!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: user.photoUrl != null
                      ? ClipOval(
                          child: Image.network(
                            user.photoUrl!,
                            fit: BoxFit.cover,
                            width: 96,
                            height: 96,
                          ),
                        )
                      : Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                if (user.isMember) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.card_membership, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          user.membershipType ?? 'Associado',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Menu Items
          _buildMenuItem(
            context,
            icon: Icons.person,
            title: 'Editar Perfil',
            onTap: () {},
          ),
          _buildMenuItem(
            context,
            icon: Icons.event,
            title: 'Os Meus Eventos',
            onTap: () {},
          ),
          _buildMenuItem(
            context,
            icon: Icons.volunteer_activism,
            title: 'As Minhas Doações',
            onTap: () {},
          ),
          _buildMenuItem(
            context,
            icon: Icons.card_membership,
            title: 'A Minha Associação',
            onTap: () => context.push(AppRoutes.membership),
          ),
          _buildMenuItem(
            context,
            icon: Icons.notifications,
            title: 'Notificações',
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _buildMenuItem(
            context,
            icon: Icons.settings,
            title: 'Definições',
            onTap: () => context.push(AppRoutes.settings),
          ),
          _buildMenuItem(
            context,
            icon: Icons.help_outline,
            title: 'Ajuda & Suporte',
            onTap: () => context.push(AppRoutes.contact),
          ),
          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            title: 'Sobre a CIL',
            onTap: () => context.push(AppRoutes.about),
          ),
          const SizedBox(height: 24),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await authProvider.logout();
              },
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text(
                'Terminar Sessão',
                style: TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestProfile(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Guest Avatar
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              size: 80,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Bem-vindo à CIL',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Faça login para aceder a todas as funcionalidades',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Login Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push(AppRoutes.login),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Entrar'),
            ),
          ),
          const SizedBox(height: 12),

          // Register Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.push(AppRoutes.register),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Criar Conta'),
            ),
          ),
          const SizedBox(height: 40),

          // Divider
          const Divider(),
          const SizedBox(height: 16),

          // Quick Links
          _buildMenuItem(
            context,
            icon: Icons.access_time,
            title: 'Horários de Oração',
            onTap: () => context.go(AppRoutes.prayerTimes),
          ),
          _buildMenuItem(
            context,
            icon: Icons.volunteer_activism,
            title: 'Fazer uma Doação',
            onTap: () => context.push(AppRoutes.donation),
          ),
          _buildMenuItem(
            context,
            icon: Icons.card_membership,
            title: 'Tornar-se Associado',
            onTap: () => context.push(AppRoutes.membership),
          ),
          _buildMenuItem(
            context,
            icon: Icons.phone,
            title: 'Contactos',
            onTap: () => context.push(AppRoutes.contact),
          ),
          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            title: 'Sobre a CIL',
            onTap: () => context.push(AppRoutes.about),
          ),
          _buildMenuItem(
            context,
            icon: Icons.settings,
            title: 'Definições',
            onTap: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondaryLight),
      ),
    );
  }
}
