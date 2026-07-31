import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/url_helper.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contactos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'Ver no Website',
            onPressed: () {
              UrlHelper.openUrl(context, AppConstants.contactUrl, title: 'Contactos - CIL');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map
            SizedBox(
              height: 200,
              child: FlutterMap(
                options: const MapOptions(
                  initialCenter: LatLng(AppConstants.mosqueLat, AppConstants.mosqueLng),
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(AppConstants.mosqueLat, AppConstants.mosqueLng),
                        child: const Icon(
                          Icons.mosque,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location
                  _buildContactCard(
                    context,
                    icon: Icons.location_on,
                    title: 'Morada',
                    subtitle: AppConstants.mosqueAddress,
                    onTap: () {
                      UrlHelper.openMaps(AppConstants.mosqueAddress);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Phone
                  _buildContactCard(
                    context,
                    icon: Icons.phone,
                    title: 'Telefone',
                    subtitle: AppConstants.phone,
                    onTap: () {
                      UrlHelper.openPhone(AppConstants.phone);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Email
                  _buildContactCard(
                    context,
                    icon: Icons.email,
                    title: 'Email',
                    subtitle: AppConstants.email,
                    onTap: () {
                      UrlHelper.openEmail(AppConstants.email);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Website
                  _buildContactCard(
                    context,
                    icon: Icons.language,
                    title: 'Website',
                    subtitle: AppConstants.websiteUrl,
                    onTap: () {
                      UrlHelper.openUrl(context, AppConstants.websiteUrl, title: 'CIL');
                    },
                  ),
                  const SizedBox(height: 24),

                  // Opening Hours
                  Text(
                    'Horário de Funcionamento',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildOpeningHours(context),
                  const SizedBox(height: 24),

                  // Social Media
                  Text(
                    'Redes Sociais',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSocialMedia(context),
                  const SizedBox(height: 24),

                  // Contact Form
                  Text(
                    'Enviar Mensagem',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildContactForm(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _buildOpeningHours(BuildContext context) {
    final hours = [
      {'day': 'Segunda a Sexta', 'hours': '09:00 - 18:00'},
      {'day': 'Sábado', 'hours': '09:00 - 13:00'},
      {'day': 'Domingo', 'hours': 'Fechado (aberto para orações)'},
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: hours.map((h) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(h['day']!),
                  Text(
                    h['hours']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSocialMedia(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSocialButton(Icons.facebook, 'Facebook', AppConstants.facebookUrl),
        _buildSocialButton(Icons.camera_alt, 'Instagram', AppConstants.instagramUrl),
        _buildSocialButton(Icons.play_circle, 'YouTube', AppConstants.youtubeUrl),
        _buildSocialButton(Icons.language, 'Website', AppConstants.websiteUrl),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String label, String url) {
    return InkWell(
      onTap: () => UrlHelper.openInBrowser(url),
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
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactForm(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nome',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Assunto',
                prefixIcon: Icon(Icons.subject),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Mensagem',
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // For now, redirect to website contact form
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Enviar Mensagem'),
                      content: const Text(
                        'Para enviar uma mensagem, será redirecionado para o formulário de contacto no website da CIL.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            UrlHelper.openUrl(context, AppConstants.contactUrl, title: 'Contactos - CIL');
                          },
                          child: const Text('Ir para Website'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Enviar Mensagem'),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  UrlHelper.openUrl(context, AppConstants.contactUrl, title: 'Contactos - CIL');
                },
                icon: const Icon(Icons.open_in_browser, size: 18),
                label: const Text('Contactar via Website'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
