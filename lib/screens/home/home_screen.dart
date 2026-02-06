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

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = context.tr;
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final upcomingEvents = ref.watch(upcomingEventsProvider);
    final isVisitor = ref.watch(isVisitorProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(upcomingEventsProvider);
          },
          child: CustomScrollView(
            slivers: [
              // Welcome Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${tr('welcome')}${currentUser != null ? ', ${currentUser.displayName}' : ''} 👋',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tr('home_subtitle'),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              // Quick Actions
              if (!isVisitor)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: _QuickActions(),
                  ),
                ),

              // Upcoming Events Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr('upcoming_events'),
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => context.go('/events'),
                        child: Text(tr('see_all')),
                      ),
                    ],
                  ),
                ),
              ),

              // Events List
              upcomingEvents.when(
                data: (events) {
                  if (events.isEmpty) {
                    return SliverToBoxAdapter(
                      child: _EmptyState(
                        icon: Icons.event_busy,
                        message: tr('no_upcoming_events'),
                      ),
                    );
                  }
                  final display = events.take(5).toList();
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.builder(
                      itemCount: display.length,
                      itemBuilder: (context, index) {
                        return _EventCard(event: display[index]);
                      },
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(48),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: _EmptyState(
                    icon: Icons.error_outline,
                    message: e.toString(),
                  ),
                ),
              ),

              // Club Info Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _ClubInfoCard(),
                ),
              ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = context.tr;
    final isAdmin = ref.watch(isAdminProvider);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _ActionChip(
          icon: Icons.calendar_month,
          label: tr('calendar'),
          onTap: () => context.go('/events/calendar'),
        ),
        _ActionChip(
          icon: Icons.leaderboard,
          label: tr('classement'),
          onTap: () => context.go('/events'),
        ),
        if (isAdmin)
          _ActionChip(
            icon: Icons.add_circle_outline,
            label: tr('new_event'),
            onTap: () => context.go('/events/create'),
          ),
        _ActionChip(
          icon: Icons.settings,
          label: tr('settings'),
          onTap: () => context.go('/profile/settings'),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return A11y.touchTarget(
      child: ActionChip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        onPressed: onTap,
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final colorMap = {
      EventType.race: AppColors.eventRace,
      EventType.trail: AppColors.eventTrail,
      EventType.training: AppColors.eventTraining,
      EventType.social: AppColors.eventSocial,
    };
    final color = colorMap[event.type] ?? AppColors.primary;
    final typeLabels = {
      EventType.race: '🏁',
      EventType.trail: '⛰️',
      EventType.training: '🏃',
      EventType.social: '🎉',
    };

    return Semantics(
      button: true,
      label:
          '${event.title}, ${event.type.name}, ${_formatDate(event.date)}',
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.go('/events/${event.id}'),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: color, width: 4),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Date badge
                  Container(
                    width: 52,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${event.date.day}',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                        ),
                        Text(
                          _monthAbbr(event.date.month),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: color,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              typeLabels[event.type] ?? '',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                event.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (event.locationName.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.5)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  event.locationName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.5),
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.people,
                                size: 14, color: color),
                            const SizedBox(width: 4),
                            Text(
                              '${event.participantCount}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: color),
                            ),
                            if (event.distance != null) ...[
                              const SizedBox(width: 12),
                              Icon(Icons.straighten,
                                  size: 14, color: color),
                              const SizedBox(width: 4),
                              Text(
                                '${event.distance} km',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: color),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _monthAbbr(int m) {
    const months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc',
    ];
    return months[m - 1];
  }

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';
}

class _ClubInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  tr('about_club'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              tr('club_description'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            A11y.touchTarget(
              child: OutlinedButton(
                onPressed: () => context.go('/club'),
                child: Text(tr('learn_more')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(icon, size: 48,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
          ),
        ],
      ),
    );
  }
}
