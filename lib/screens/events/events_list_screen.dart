import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/event_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/accessibility/a11y.dart';
import '../../core/constants/enums.dart';
import '../../models/event_model.dart';

class EventsListScreen extends ConsumerWidget {
  const EventsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = context.tr;
    final tab = ref.watch(selectedEventTabProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return DefaultTabController(
      length: 3,
      initialIndex: tab,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('events')),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_month),
              tooltip: tr('calendar'),
              onPressed: () => context.go('/events/calendar'),
            ),
          ],
          bottom: TabBar(
            onTap: (i) =>
                ref.read(selectedEventTabProvider.notifier).state = i,
            tabs: [
              Tab(text: tr('upcoming')),
              Tab(text: tr('past')),
              Tab(text: tr('all')),
            ],
          ),
        ),
        floatingActionButton: isAdmin
            ? A11y.label(
                label: tr('new_event'),
                child: FloatingActionButton.extended(
                  onPressed: () => context.go('/events/create'),
                  icon: const Icon(Icons.add),
                  label: Text(tr('new_event')),
                ),
              )
            : null,
        body: TabBarView(
          children: [
            _EventTab(provider: upcomingEventsProvider),
            _EventTab(provider: pastEventsProvider),
            _EventTab(provider: allEventsProvider),
          ],
        ),
      ),
    );
  }
}

class _EventTab extends ConsumerWidget {
  final ProviderBase<AsyncValue<List<EventModel>>> provider;
  const _EventTab({required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = context.tr;
    final events = ref.watch(provider);

    return events.when(
      data: (list) {
        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.event_busy, size: 64,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text(tr('no_events'),
                    style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, i) => _EventListTile(event: list[i]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
    );
  }
}

class _EventListTile extends StatelessWidget {
  final EventModel event;
  const _EventListTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(event.type);

    return Semantics(
      button: true,
      label: '${event.title}, ${event.locationName}, ${event.date.day}/${event.date.month}/${event.date.year}',
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.go('/events/${event.id}'),
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: color, width: 4)),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Date
                _DateBadge(date: event.date, color: color),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.location_on,
                            text: event.locationName,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.people,
                            text: '${event.participantCount}',
                          ),
                          if (event.distance != null) ...[
                            const SizedBox(width: 12),
                            _InfoChip(
                              icon: Icons.straighten,
                              text: '${event.distance} km',
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Status chip
                _StatusChip(status: event.computedStatus),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _typeColor(EventType type) {
    switch (type) {
      case EventType.race:
        return AppColors.eventRace;
      case EventType.trail:
        return AppColors.eventTrail;
      case EventType.training:
        return AppColors.eventTraining;
      case EventType.social:
        return AppColors.eventSocial;
    }
  }
}

class _DateBadge extends StatelessWidget {
  final DateTime date;
  final Color color;
  const _DateBadge({required this.date, required this.color});

  @override
  Widget build(BuildContext context) {
    const months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc',
    ];
    return Container(
      width: 52,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text('${date.day}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold, color: color)),
          Text(months[date.month - 1],
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.5)),
        const SizedBox(width: 4),
        Text(text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final EventStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      EventStatus.upcoming => (AppColors.eventUpcoming, '⏳'),
      EventStatus.ongoing => (AppColors.eventOngoing, '🔴'),
      EventStatus.completed => (AppColors.eventCompleted, '✅'),
      EventStatus.cancelled => (AppColors.eventCancelled, '❌'),
    };
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(child: Text(label, style: const TextStyle(fontSize: 14))),
    );
  }
}
