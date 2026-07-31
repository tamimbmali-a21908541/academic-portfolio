import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/events_service.dart';
import '../../../core/utils/url_helper.dart';

class EventDetailScreen extends StatelessWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventsProvider>(
      builder: (context, provider, _) {
        final event = provider.events?.firstWhere(
          (e) => e.id == eventId,
          orElse: () => EventItem(
            id: '',
            title: '',
            description: '',
            date: DateTime.now(),
            time: '',
            location: '',
            imageUrl: '',
            category: '',
          ),
        );

        if (event == null || event.id.isEmpty) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Evento não encontrado')),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App Bar with Image
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: event.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.primary.withOpacity(0.1),
                          child: const Icon(Icons.event, size: 64, color: AppColors.primary),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  if (event.webUrl.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.open_in_browser),
                      tooltip: 'Ver no Website',
                      onPressed: () {
                        UrlHelper.openUrl(context, event.webUrl, title: event.title);
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      final shareUrl = event.webUrl.isNotEmpty
                          ? event.webUrl
                          : EventsService.eventsPageUrl;
                      final dateStr = DateFormat('dd/MM/yyyy').format(event.date);
                      Share.share(
                        '${event.title}\n\n$dateStr - ${event.time}\n${event.location}\n\n$shareUrl',
                        subject: event.title,
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    tooltip: 'Adicionar ao calendário',
                    onPressed: () {
                      // Add to calendar - would integrate with device calendar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Funcionalidade de calendário em desenvolvimento'),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category & Status
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              event.category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (event.isToday)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'HOJE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (event.isRecurring) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.info,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.repeat, size: 12, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'Recorrente',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Date, Time, Location Cards
                      _buildInfoCard(
                        context,
                        Icons.calendar_today,
                        'Data',
                        DateFormat('EEEE, dd MMMM yyyy', 'pt_PT').format(event.date),
                        AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        context,
                        Icons.access_time,
                        'Horário',
                        event.endTime != null ? '${event.time} - ${event.endTime}' : event.time,
                        AppColors.secondary,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        context,
                        Icons.location_on,
                        'Local',
                        event.location,
                        AppColors.accent,
                        onTap: () {
                          UrlHelper.openMaps(event.location);
                        },
                      ),

                      // Price
                      if (!event.isFree) ...[
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          context,
                          Icons.euro,
                          'Preço',
                          '${event.price?.toStringAsFixed(2)}€',
                          AppColors.warning,
                        ),
                      ],

                      // Attendees
                      if (event.maxAttendees != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          context,
                          Icons.people,
                          'Vagas',
                          '${event.currentAttendees ?? 0} / ${event.maxAttendees}',
                          AppColors.info,
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Description
                      Text(
                        'Descrição',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        event.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // View on Website Button
                      if (event.webUrl.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              UrlHelper.openUrl(context, event.webUrl, title: event.title);
                            },
                            icon: const Icon(Icons.open_in_browser),
                            label: const Text('Ver Mais Detalhes no Website'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: event.requiresRegistration
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: ElevatedButton(
                      onPressed: event.hasAvailableSpots
                          ? () {
                              // Open registration - use registrationUrl or webUrl
                              final url = event.registrationUrl ?? event.webUrl;
                              if (url.isNotEmpty) {
                                UrlHelper.openUrl(context, url, title: 'Inscrição - ${event.title}');
                              } else {
                                // Fallback to events page
                                UrlHelper.openUrl(context, EventsService.eventsPageUrl, title: 'Eventos');
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: event.hasAvailableSpots ? AppColors.primary : Colors.grey,
                      ),
                      child: Text(
                        event.hasAvailableSpots ? 'Inscrever-me' : 'Esgotado',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
