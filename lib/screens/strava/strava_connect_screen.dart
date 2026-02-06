import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/accessibility/a11y.dart';
import '../../services/strava_service.dart';

final _stravaServiceProvider = Provider<StravaService>((ref) {
  return StravaService();
});

class StravaConnectScreen extends ConsumerStatefulWidget {
  const StravaConnectScreen({super.key});

  @override
  ConsumerState<StravaConnectScreen> createState() =>
      _StravaConnectScreenState();
}

class _StravaConnectScreenState extends ConsumerState<StravaConnectScreen> {
  bool _isConnecting = false;
  bool _isDisconnecting = false;

  Future<void> _connect() async {
    setState(() => _isConnecting = true);
    try {
      final service = ref.read(_stravaServiceProvider);
      await service.authenticate();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('strava_connected'))),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  Future<void> _disconnect() async {
    setState(() => _isDisconnecting = true);
    try {
      final service = ref.read(_stravaServiceProvider);
      final user = ref.read(currentUserProvider).valueOrNull;
      await service.disconnect(user?.id ?? '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('strava_disconnected'))),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDisconnecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final user = ref.watch(currentUserProvider).valueOrNull;
    final isConnected = user?.stravaAthleteId != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Strava')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Strava branding
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.stravaOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.stravaOrange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.flash_on,
                        size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Strava',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.stravaOrange,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr('strava_description'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      isConnected ? Icons.check_circle : Icons.cancel,
                      color: isConnected
                          ? AppColors.accent
                          : AppColors.error,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isConnected
                                ? tr('strava_connected')
                                : tr('strava_not_connected'),
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (isConnected && user?.stravaAthleteId != null)
                            Text(
                              'Athlete ID: ${user!.stravaAthleteId}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action
            if (!isConnected)
              A11y.touchTarget(
                child: FilledButton.icon(
                  onPressed: _isConnecting ? null : _connect,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.stravaOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: _isConnecting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.link),
                  label: Text(tr('connect_strava')),
                ),
              )
            else
              A11y.touchTarget(
                child: OutlinedButton.icon(
                  onPressed: _isDisconnecting ? null : _disconnect,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: _isDisconnecting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.link_off),
                  label: Text(tr('disconnect_strava')),
                ),
              ),
            const SizedBox(height: 32),

            // Features
            Text(
              tr('strava_features'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _FeatureTile(
              icon: Icons.sync,
              title: tr('auto_sync'),
              subtitle: tr('auto_sync_desc'),
            ),
            _FeatureTile(
              icon: Icons.leaderboard,
              title: tr('classement'),
              subtitle: tr('classement_desc'),
            ),
            _FeatureTile(
              icon: Icons.timeline,
              title: tr('performance'),
              subtitle: tr('performance_desc'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.stravaOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                Icon(icon, color: AppColors.stravaOrange, size: 20),
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
