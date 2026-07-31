import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Mosque Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Sobre a CIL'),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: 'https://static.wixstatic.com/media/99b369_d881c5966b25444fb7319ba6f7748424~mv2.jpg',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Comunidade Islâmica de Lisboa',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    '''A Comunidade Islâmica de Lisboa (CIL) é uma das principais instituições representativas dos muçulmanos em Portugal, desempenhando um papel fundamental na promoção do diálogo inter-religioso, da integração social e da preservação da identidade cultural islâmica no país.

Fundada em 1968, a CIL tem sido um ponto de encontro para muçulmanos de diversas origens, incluindo comunidades provenientes de Moçambique, Guiné-Bissau, Índia, Paquistão, Bangladesh e do mundo árabe.''',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 24),

                  // Mosque Section
                  Text(
                    'Mesquita Central de Lisboa',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '''O maior símbolo da presença islâmica em Portugal é a Mesquita Central de Lisboa, inaugurada em 1985. Localizada na Praça de Espanha, esta mesquita não é apenas um local de oração, mas também um centro de educação e cultura islâmica.

Com uma arquitetura impressionante, inspirada no estilo islâmico tradicional, a mesquita conta com:

• Sala de oração ampla de dois pisos
• Biblioteca
• Salas de ensino
• Centro de convívio
• Refeitório com restaurante
• Pavilhão desportivo
• Salão nobre para conferências e eventos
• Sala fúnebre''',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 24),

                  // Facilities
                  Text(
                    'Instalações',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFacilityGrid(context),
                  const SizedBox(height: 24),

                  // Mission
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.flag, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Nossa Missão',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Fortalecer a coexistência pacífica e a compreensão mútua entre as diferentes comunidades religiosas e culturais em Portugal, reforçando a importância do respeito e da diversidade.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Social Links
                  Text(
                    'Siga-nos',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSocialLinks(context),
                  const SizedBox(height: 32),

                  // App Info & Developer Credit
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildAppInfo(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          // App Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/icons/app_icon.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppConstants.appName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Versão ${AppConstants.appVersion}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.code, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Desenvolvido por Tamim Mohamed Ali',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '© ${DateTime.now().year} Comunidade Islâmica de Lisboa',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityGrid(BuildContext context) {
    final facilities = [
      {'icon': Icons.mosque, 'name': 'Sala de Oração'},
      {'icon': Icons.menu_book, 'name': 'Biblioteca'},
      {'icon': Icons.school, 'name': 'Salas de Ensino'},
      {'icon': Icons.restaurant, 'name': 'Restaurante'},
      {'icon': Icons.sports_soccer, 'name': 'Pavilhão Desportivo'},
      {'icon': Icons.celebration, 'name': 'Salão Nobre'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: facilities.length,
      itemBuilder: (context, index) {
        final facility = facilities[index];
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(facility['icon'] as IconData, color: AppColors.primary, size: 28),
              const SizedBox(height: 8),
              Text(
                facility['name'] as String,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSocialLinks(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSocialButton(Icons.language, 'Website', () => launchUrl(Uri.parse(AppConstants.websiteUrl))),
        _buildSocialButton(Icons.facebook, 'Facebook', () => launchUrl(Uri.parse(AppConstants.facebookUrl))),
        _buildSocialButton(Icons.camera_alt, 'Instagram', () => launchUrl(Uri.parse(AppConstants.instagramUrl))),
        _buildSocialButton(Icons.play_circle, 'YouTube', () => launchUrl(Uri.parse(AppConstants.youtubeUrl))),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
