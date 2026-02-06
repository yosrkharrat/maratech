import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/event_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/accessibility/a11y.dart';
import '../../core/constants/enums.dart';
import '../../services/event_service.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = context.tr;
    final user = ref.watch(currentUserProvider).valueOrNull;

    if (user == null || !user.role.canManageEvents) {
      return Scaffold(
        body: Center(child: Text(tr('access_denied'))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('admin')),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/profile/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome
            Text(
              '${tr('welcome')}, ${user.displayName}',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${tr('role')}: ${user.role.name}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 24),

            // Stats
            _StatsGrid(),
            const SizedBox(height: 24),

            // Quick actions
            Text(
              tr('quick_actions'),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _AdminAction(
              icon: Icons.people,
              title: tr('manage_users'),
              subtitle: tr('manage_users_desc'),
              color: AppColors.primary,
              onTap: () => context.go('/admin/users'),
            ),
            _AdminAction(
              icon: Icons.add_circle,
              title: tr('new_event'),
              subtitle: tr('new_event_desc'),
              color: AppColors.accent,
              onTap: () => context.go('/events/create'),
            ),
            _AdminAction(
              icon: Icons.directions_run,
              title: tr('events'),
              subtitle: tr('view_all_events'),
              color: AppColors.secondary,
              onTap: () => context.go('/events'),
            ),
            _AdminAction(
              icon: Icons.person,
              title: tr('profile'),
              subtitle: tr('view_profile'),
              color: Colors.teal,
              onTap: () => context.go('/profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = context.tr;
    final allUsers = ref.watch(allUsersProvider);
    final allEvents = ref.watch(allEventsProvider);

    final userCount = allUsers.when(
      data: (list) => list.length,
      loading: () => 0,
      error: (_, __) => 0,
    );
    final eventCount = allEvents.when(
      data: (list) => list.length,
      loading: () => 0,
      error: (_, __) => 0,
    );
    final upcomingCount = allEvents.when(
      data: (list) =>
          list.where((e) => e.computedStatus == EventStatus.upcoming).length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.people,
            value: '$userCount',
            label: tr('members'),
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.event,
            value: '$eventCount',
            label: tr('events'),
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.upcoming,
            value: '$upcomingCount',
            label: tr('upcoming'),
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      )),
              Text(label,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AdminAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return A11y.touchTarget(
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          title: Text(title,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}
