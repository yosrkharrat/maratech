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
import '../../services/event_service.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = context.tr;
    final eventAsync = ref.watch(eventDetailProvider(eventId));
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final isVisitor = ref.watch(isVisitorProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return eventAsync.when(
      data: (event) {
        if (event == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(tr('event_not_found'))),
          );
        }
        return _EventDetailContent(
          event: event,
          userId: currentUser?.id ?? '',
          isVisitor: isVisitor,
          isAdmin: isAdmin,
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(e.toString())),
      ),
    );
  }
}

class _EventDetailContent extends ConsumerWidget {
  final EventModel event;
  final String userId;
  final bool isVisitor;
  final bool isAdmin;

  const _EventDetailContent({
    required this.event,
    required this.userId,
    required this.isVisitor,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = context.tr;
    final color = _typeColor(event.type);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                event.title,
                style: const TextStyle(
                  shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                ),
                child: Icon(
                  _typeIcon(event.type),
                  size: 80,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ),
            actions: [
              if (isAdmin)
                PopupMenuButton<String>(
                  onSelected: (action) async {
                    if (action == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(tr('confirm_delete')),
                          content: Text(tr('delete_event_confirm')),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(tr('cancel')),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.error),
                              child: Text(tr('delete')),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        await ref
                            .read(eventServiceProvider)
                            .deleteEvent(event.id);
                        if (context.mounted) context.go('/events');
                      }
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, color: AppColors.error),
                          const SizedBox(width: 8),
                          Text(tr('delete')),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Status + Type chips
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      avatar: Icon(_statusIcon(event.computedStatus),
                          size: 16, color: Colors.white),
                      label: Text(event.computedStatus.name),
                      backgroundColor:
                          _statusColor(event.computedStatus),
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                    Chip(
                      label: Text(event.type.name),
                      backgroundColor: color.withValues(alpha: 0.2),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Info rows
                _InfoRow(
                  icon: Icons.calendar_today,
                  label: tr('date'),
                  value:
                      '${event.date.day}/${event.date.month}/${event.date.year} ${event.date.hour.toString().padLeft(2, '0')}:${event.date.minute.toString().padLeft(2, '0')}',
                ),
                if (event.endDate != null)
                  _InfoRow(
                    icon: Icons.event_available,
                    label: tr('end_date'),
                    value:
                        '${event.endDate!.day}/${event.endDate!.month}/${event.endDate!.year}',
                  ),
                _InfoRow(
                  icon: Icons.location_on,
                  label: tr('venue'),
                  value: event.locationName,
                ),
                if (event.distance != null)
                  _InfoRow(
                    icon: Icons.straighten,
                    label: tr('distance'),
                    value: '${event.distance} km',
                  ),
                _InfoRow(
                  icon: Icons.people,
                  label: tr('participants'),
                  value: '${event.participantCount}',
                ),
                _InfoRow(
                  icon: Icons.favorite,
                  label: tr('interested'),
                  value: '${event.interestedCount}',
                ),

                const SizedBox(height: 20),

                // Description
                Text(tr('description'),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(event.description,
                    style: Theme.of(context).textTheme.bodyLarge),

                const SizedBox(height: 24),

                // Participation buttons
                if (!isVisitor) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _ParticipationButton(
                          label: tr('participate'),
                          icon: Icons.check_circle,
                          isActive: event.isUserParticipant(userId),
                          color: AppColors.participantColor,
                          onTap: () => _toggleParticipation(
                              ref, ParticipationRole.participant),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ParticipationButton(
                          label: tr('interested'),
                          icon: Icons.favorite,
                          isActive: event.isUserInterested(userId),
                          color: AppColors.interestedColor,
                          onTap: () => _toggleParticipation(
                              ref, ParticipationRole.interested),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Action buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    A11y.touchTarget(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            context.go('/events/${event.id}/gallery'),
                        icon: const Icon(Icons.photo_library),
                        label: Text(tr('gallery')),
                      ),
                    ),
                    if (!isVisitor)
                      A11y.touchTarget(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              context.go('/events/${event.id}/upload'),
                          icon: const Icon(Icons.upload),
                          label: Text(tr('upload')),
                        ),
                      ),
                    A11y.touchTarget(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            context.go('/events/${event.id}/classement'),
                        icon: const Icon(Icons.leaderboard),
                        label: Text(tr('classement')),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleParticipation(WidgetRef ref, ParticipationRole role) {
    ref
        .read(eventServiceProvider)
        .toggleParticipation(event.id, userId, role);
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

  IconData _typeIcon(EventType type) {
    switch (type) {
      case EventType.race:
        return Icons.emoji_events;
      case EventType.trail:
        return Icons.terrain;
      case EventType.training:
        return Icons.fitness_center;
      case EventType.social:
        return Icons.celebration;
    }
  }

  IconData _statusIcon(EventStatus s) {
    switch (s) {
      case EventStatus.upcoming:
        return Icons.schedule;
      case EventStatus.ongoing:
        return Icons.play_arrow;
      case EventStatus.completed:
        return Icons.check;
      case EventStatus.cancelled:
        return Icons.close;
    }
  }

  Color _statusColor(EventStatus s) {
    switch (s) {
      case EventStatus.upcoming:
        return AppColors.eventUpcoming;
      case EventStatus.ongoing:
        return AppColors.eventOngoing;
      case EventStatus.completed:
        return AppColors.eventCompleted;
      case EventStatus.cancelled:
        return AppColors.eventCancelled;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text('$label: ',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _ParticipationButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _ParticipationButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return A11y.touchTarget(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isActive ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border:
              isActive ? null : Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon,
                      size: 20,
                      color: isActive ? Colors.white : color),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: isActive ? Colors.white : color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
