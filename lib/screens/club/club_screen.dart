import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/accessibility/a11y.dart';

class ClubScreen extends ConsumerWidget {
  const ClubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = context.tr;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.directions_run,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppConstants.appName,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'RCT',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white70,
                            letterSpacing: 6,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // About
                  _Section(
                    title: tr('about_club'),
                    icon: Icons.info_outline,
                    child: Text(
                      tr('club_description'),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // History
                  _Section(
                    title: tr('history'),
                    icon: Icons.history_edu,
                    child: Text(
                      tr('club_history'),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Values
                  _Section(
                    title: tr('values'),
                    icon: Icons.favorite,
                    child: Column(
                      children: [
                        _ValueTile(
                          icon: Icons.groups,
                          title: tr('value_community'),
                          subtitle: tr('value_community_desc'),
                        ),
                        _ValueTile(
                          icon: Icons.accessibility_new,
                          title: tr('value_inclusion'),
                          subtitle: tr('value_inclusion_desc'),
                        ),
                        _ValueTile(
                          icon: Icons.emoji_events,
                          title: tr('value_excellence'),
                          subtitle: tr('value_excellence_desc'),
                        ),
                        _ValueTile(
                          icon: Icons.volunteer_activism,
                          title: tr('value_passion'),
                          subtitle: tr('value_passion_desc'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Contact
                  _Section(
                    title: tr('contact'),
                    icon: Icons.contact_mail,
                    child: Column(
                      children: [
                        _ContactTile(
                          icon: Icons.location_on,
                          label: AppConstants.clubAddress,
                          onTap: null,
                        ),
                        _ContactTile(
                          icon: Icons.phone,
                          label: AppConstants.clubPhone,
                          onTap: () => _launch('tel:${AppConstants.clubPhone}'),
                        ),
                        _ContactTile(
                          icon: Icons.email,
                          label: AppConstants.clubEmail,
                          onTap: () =>
                              _launch('mailto:${AppConstants.clubEmail}'),
                        ),
                        _ContactTile(
                          icon: Icons.facebook,
                          label: 'Facebook',
                          onTap: () =>
                              _launch(AppConstants.clubFacebook),
                        ),
                        _ContactTile(
                          icon: Icons.camera_alt,
                          label: 'Instagram',
                          onTap: () =>
                              _launch(AppConstants.clubInstagram),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _Section({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _ValueTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ValueTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return A11y.touchTarget(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label),
        trailing: onTap != null
            ? const Icon(Icons.open_in_new, size: 16)
            : null,
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
