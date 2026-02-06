import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/providers/strava_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/accessibility/a11y.dart';
import '../../core/constants/enums.dart';
import '../../models/media_model.dart';

class ClassementScreen extends ConsumerWidget {
  final String eventId;
  const ClassementScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = context.tr;
    final criteria = ref.watch(classementCriteriaProvider);
    final classementAsync = ref.watch(classementProvider(eventId));

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('classement')),
        actions: [
          PopupMenuButton<ClassementCriteria>(
            icon: const Icon(Icons.sort),
            tooltip: tr('sort_by'),
            onSelected: (v) =>
                ref.read(classementCriteriaProvider.notifier).state = v,
            itemBuilder: (_) => ClassementCriteria.values
                .map((c) => PopupMenuItem(
                      value: c,
                      child: Row(
                        children: [
                          if (criteria == c)
                            const Icon(Icons.check,
                                size: 16, color: AppColors.primary),
                          if (criteria == c) const SizedBox(width: 8),
                          Text(_criteriaLabel(c, tr)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
      body: classementAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.leaderboard, size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(tr('no_classement'),
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text(tr('classement_empty_hint'),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center),
                ],
              ),
            );
          }

          // Sort client-side by criteria
          final sorted = List<ClassementEntry>.from(entries);
          sorted.sort((a, b) {
            switch (criteria) {
              case ClassementCriteria.time:
                return a.movingTime.compareTo(b.movingTime);
              case ClassementCriteria.pace:
                return a.pace.compareTo(b.pace);
              case ClassementCriteria.distance:
                return b.distance.compareTo(a.distance); // desc
            }
          });

          return Column(
            children: [
              // Top 3 podium
              if (sorted.length >= 3)
                _Podium(top3: sorted.take(3).toList()),
              const Divider(height: 1),

              // Full list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: sorted.length,
                  itemBuilder: (context, i) {
                    return _ClassementTile(
                      entry: sorted[i],
                      rank: i + 1,
                      criteria: criteria,
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }

  String _criteriaLabel(ClassementCriteria c, String Function(String) tr) {
    switch (c) {
      case ClassementCriteria.time:
        return tr('sort_time');
      case ClassementCriteria.pace:
        return tr('sort_pace');
      case ClassementCriteria.distance:
        return tr('sort_distance');
    }
  }
}

class _Podium extends StatelessWidget {
  final List<ClassementEntry> top3;
  const _Podium({required this.top3});

  @override
  Widget build(BuildContext context) {
    final medals = [AppColors.medalGold, AppColors.medalSilver, AppColors.medalBronze];
    final heights = [100.0, 80.0, 60.0];
    final order = [1, 0, 2]; // Silver - Gold - Bronze positioning

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: order.map((i) {
          if (i >= top3.length) return const SizedBox(width: 80);
          final entry = top3[i];
          return Expanded(
            child: Semantics(
              label: '${i + 1}${_suffix(i + 1)} place: ${entry.userName}, ${_formatTime(entry.movingTime)}',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Medal icon
                  Icon(Icons.emoji_events,
                      color: medals[i], size: i == 0 ? 40 : 30),
                  const SizedBox(height: 4),
                  // Name
                  Text(
                    entry.userName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(entry.movingTime),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  // Podium bar
                  Container(
                    height: heights[i],
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: medals[i].withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: medals[i],
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _suffix(int n) {
    switch (n) {
      case 1:
        return 'er';
      default:
        return 'ème';
    }
  }
}

class _ClassementTile extends StatelessWidget {
  final ClassementEntry entry;
  final int rank;
  final ClassementCriteria criteria;

  const _ClassementTile({
    required this.entry,
    required this.rank,
    required this.criteria,
  });

  @override
  Widget build(BuildContext context) {
    final medalColors = {
      1: AppColors.medalGold,
      2: AppColors.medalSilver,
      3: AppColors.medalBronze,
    };
    final color = medalColors[rank];

    return Semantics(
      label: 'Rank $rank: ${entry.userName}',
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Rank
              SizedBox(
                width: 40,
                child: color != null
                    ? Icon(Icons.emoji_events, color: color, size: 24)
                    : Text(
                        '#$rank',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
              ),
              const SizedBox(width: 12),
              // Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.userName,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${entry.distance.toStringAsFixed(1)} km',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              // Stats
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(entry.movingTime),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  Text(
                    '${entry.pace} min/km',
                    style: Theme.of(context).textTheme.bodySmall,
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

String _formatTime(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  if (h > 0) {
    return '${h}h ${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}
