import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';

// Service provider
final eventServiceProvider =
    Provider<EventService>((ref) => EventService());

// All events stream
final allEventsProvider = StreamProvider<List<EventModel>>((ref) {
  return ref.read(eventServiceProvider).streamAllEvents();
});

// Upcoming events
final upcomingEventsProvider = StreamProvider<List<EventModel>>((ref) {
  return ref.read(eventServiceProvider).streamUpcomingEvents(limit: 10);
});

// Past events
final pastEventsProvider = StreamProvider<List<EventModel>>((ref) {
  return ref.read(eventServiceProvider).streamPastEvents(limit: 20);
});

// Single event
final eventDetailProvider =
    StreamProvider.family<EventModel?, String>((ref, eventId) {
  return ref.read(eventServiceProvider).streamEvent(eventId);
});

// Events by group
final eventsByGroupProvider =
    StreamProvider.family<List<EventModel>, String>((ref, groupId) {
  return ref.read(eventServiceProvider).streamEventsByGroup(groupId);
});

// Events by date range (for calendar)
final eventsByDateRangeProvider = StreamProvider.family<List<EventModel>,
    ({DateTime start, DateTime end})>((ref, range) {
  return ref
      .read(eventServiceProvider)
      .streamEventsByDateRange(range.start, range.end);
});

// Selected event tab index
final selectedEventTabProvider = StateProvider<int>((ref) => 0);

// Calendar selected day
final selectedCalendarDayProvider =
    StateProvider<DateTime>((ref) => DateTime.now());

// Calendar focused day
final focusedCalendarDayProvider =
    StateProvider<DateTime>((ref) => DateTime.now());
