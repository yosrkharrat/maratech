import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/accessibility/a11y.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = context.tr;
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(tr('not_logged_in')),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/login'),
                child: Text(tr('login')),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Avatar
              Semantics(
                label: '${tr('profile')} ${user.displayName}',
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  backgroundImage: user.profilePhotoUrl != null
                      ? NetworkImage(user.profilePhotoUrl!)
                      : null,
                  child: user.profilePhotoUrl == null
                      ? Text(
                          user.displayName.isNotEmpty
                              ? user.displayName[0].toUpperCase()
                              : '?',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(color: AppColors.primary),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              // Name
              Text(
                user.displayName,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),

              // Role badge
              Chip(
                label: Text(
                  user.role.name,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(height: 24),

              // Info cards
              _InfoCard(
                children: [
                  _InfoRow(
                    icon: Icons.email,
                    label: tr('email'),
                    value: user.email.isNotEmpty ? user.email : '—',
                  ),
                  _InfoRow(
                    icon: Icons.phone,
                    label: tr('phone'),
                    value: user.phone.isNotEmpty ? user.phone : '—',
                  ),
                  _InfoRow(
                    icon: Icons.groups,
                    label: tr('group'),
                    value: user.groupId ?? tr('no_group'),
                  ),
                  if (user.stravaAthleteId != null)
                    _InfoRow(
                      icon: Icons.flash_on,
                      label: 'Strava',
                      value: tr('connected'),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Actions
              _InfoCard(
                children: [
                  A11y.touchTarget(
                    child: ListTile(
                      leading: const Icon(Icons.settings,
                          color: AppColors.primary),
                      title: Text(tr('settings')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go('/profile/settings'),
                    ),
                  ),
                  A11y.touchTarget(
                    child: ListTile(
                      leading: const Icon(Icons.flash_on,
                          color: AppColors.stravaOrange),
                      title: Text('Strava'),
                      subtitle: Text(user.stravaAthleteId != null
                          ? tr('connected')
                          : tr('not_connected')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go('/profile/strava'),
                    ),
                  ),
                  const Divider(),
                  A11y.touchTarget(
                    child: ListTile(
                      leading:
                          const Icon(Icons.logout, color: AppColors.error),
                      title: Text(tr('logout'),
                          style: const TextStyle(color: AppColors.error)),
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(tr('logout')),
                            content: Text(tr('logout_confirm')),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(tr('cancel')),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(tr('logout')),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref
                              .read(currentUserProvider.notifier)
                              .logout();
                          if (context.mounted) context.go('/login');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: children),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}
