import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/events_service.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadEvents() {
    context.read<EventsProvider>().fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Próximos'),
            Tab(text: 'Todos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUpcomingEvents(),
          _buildAllEvents(),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return Consumer<EventsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.upcomingEvents == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null || provider.upcomingEvents == null) {
          return _buildErrorState();
        }

        if (provider.upcomingEvents!.isEmpty) {
          return _buildEmptyState('Sem eventos próximos');
        }

        return RefreshIndicator(
          onRefresh: () async => _loadEvents(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.upcomingEvents!.length,
            itemBuilder: (context, index) {
              return _buildEventCard(provider.upcomingEvents![index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildAllEvents() {
    return Consumer<EventsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.events == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null || provider.events == null) {
          return _buildErrorState();
        }

        if (provider.events!.isEmpty) {
          return _buildEmptyState('Sem eventos');
        }

        return RefreshIndicator(
          onRefresh: () async => _loadEvents(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.events!.length,
            itemBuilder: (context, index) {
              return _buildEventCard(provider.events![index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildEventCard(EventItem event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.push('/events/${event.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: event.imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 150,
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 150,
                    color: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.event, size: 64, color: AppColors.primary),
                  ),
                ),
                // Date Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: event.isToday ? AppColors.secondary : AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('dd').format(event.date),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('MMM', 'pt_PT').format(event.date).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Today Badge
                if (event.isToday)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'HOJE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Recurring Badge
                if (event.isRecurring)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.repeat, size: 16, color: AppColors.primary),
                    ),
                  ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(event.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      event.category,
                      style: TextStyle(
                        color: _getCategoryColor(event.category),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Time & Location
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: AppColors.textSecondaryLight),
                      const SizedBox(width: 4),
                      Text(
                        event.time,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on, size: 16, color: AppColors.textSecondaryLight),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  // Price & Registration
                  if (!event.isFree || event.requiresRegistration) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (!event.isFree)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${event.price?.toStringAsFixed(2)}€',
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (!event.isFree && event.requiresRegistration)
                          const SizedBox(width: 8),
                        if (event.requiresRegistration)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.how_to_reg, size: 14, color: AppColors.info),
                                SizedBox(width: 4),
                                Text(
                                  'Inscrição',
                                  style: TextStyle(
                                    color: AppColors.info,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Oração': return AppColors.fajrColor;
      case 'Educação': return AppColors.info;
      case 'Ramadão': return AppColors.secondary;
      case 'Conferência': return AppColors.accent;
      case 'Desporto': return AppColors.success;
      case 'Cultura': return AppColors.asrColor;
      default: return AppColors.primary;
    }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          const Text('Erro ao carregar eventos'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadEvents,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
