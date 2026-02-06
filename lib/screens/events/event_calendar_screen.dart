import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/providers/event_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/enums.dart';
import '../../models/event_model.dart';

class EventCalendarScreen extends ConsumerWidget {
  const EventCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = context.tr;
    final allEvents = ref.watch(allEventsProvider);
    final focusedDay = ref.watch(focusedCalendarDayProvider);
    final selectedDay = ref.watch(selectedCalendarDayProvider);

    return Scaffold(
      appBar: AppBar(title: Text(tr('calendar'))),
      body: allEvents.when(
        data: (events) {
          // Group events by date
          final eventsByDay = <DateTime, List<EventModel>>{};
          for (final e in events) {
            final key = DateTime(e.date.year, e.date.month, e.date.day);
            eventsByDay.putIfAbsent(key, () => []).add(e);
          }

          final selectedKey = selectedDay != null
              ? DateTime(selectedDay.year, selectedDay.month, selectedDay.day)
              : null;
          final dayEvents = selectedKey != null
              ? (eventsByDay[selectedKey] ?? [])
              : <EventModel>[];

          return Column(
            children: [
              TableCalendar<EventModel>(
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365 * 2)),
                focusedDay: focusedDay,
                selectedDayPredicate: (day) =>
                    selectedDay != null && isSameDay(day, selectedDay),
                eventLoader: (day) {
                  final key = DateTime(day.year, day.month, day.day);
                  return eventsByDay[key] ?? [];
                },
                onDaySelected: (selected, focused) {
                  ref.read(selectedCalendarDayProvider.notifier).state =
                      selected;
                  ref.read(focusedCalendarDayProvider.notifier).state =
                      focused;
                },
                onPageChanged: (focused) {
                  ref.read(focusedCalendarDayProvider.notifier).state =
                      focused;
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  markerSize: 6,
                  markersMaxCount: 3,
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle:
                      Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                ),
              ),
              const Divider(height: 1),

              // Day events
              Expanded(
                child: dayEvents.isEmpty
                    ? Center(
                        child: Text(
                          tr('no_events_on_day'),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),
                              ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: dayEvents.length,
                        itemBuilder: (context, i) {
                          final e = dayEvents[i];
                          return _CalendarEventTile(event: e);
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
}

class _CalendarEventTile extends StatelessWidget {
  final EventModel event;
  const _CalendarEventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final colorMap = {
      EventType.race: AppColors.eventRace,
      EventType.trail: AppColors.eventTrail,
      EventType.training: AppColors.eventTraining,
      EventType.social: AppColors.eventSocial,
    };
    final color = colorMap[event.type] ?? AppColors.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(
            _icon(event.type),
            color: color,
            size: 20,
          ),
        ),
        title: Text(event.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${event.date.hour.toString().padLeft(2, '0')}:${event.date.minute.toString().padLeft(2, '0')} • ${event.locationName}',
        ),
        trailing: Chip(
          label: Text('${event.participantCount}'),
          avatar: const Icon(Icons.people, size: 16),
          visualDensity: VisualDensity.compact,
        ),
        onTap: () => context.go('/events/${event.id}'),
      ),
    );
  }

  IconData _icon(EventType type) {
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
}
