import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/enums.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _eventsRef =>
      _firestore.collection(AppConstants.eventsCollection);

  /// Create a new event
  Future<EventModel> createEvent(EventModel event) async {
    final docRef = await _eventsRef.add(event.toFirestore());
    return event.copyWith(id: docRef.id);
  }

  /// Update an event
  Future<void> updateEvent(String eventId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _eventsRef.doc(eventId).update(data);
  }

  /// Delete an event and all sub-collections
  Future<void> deleteEvent(String eventId) async {
    // Delete sub-collections
    final mediaDocs = await _eventsRef
        .doc(eventId)
        .collection('media')
        .get();
    for (final doc in mediaDocs.docs) {
      await doc.reference.delete();
    }

    final notesDocs = await _eventsRef
        .doc(eventId)
        .collection('notes')
        .get();
    for (final doc in notesDocs.docs) {
      await doc.reference.delete();
    }

    final classementDocs = await _eventsRef
        .doc(eventId)
        .collection('classement')
        .get();
    for (final doc in classementDocs.docs) {
      await doc.reference.delete();
    }

    await _eventsRef.doc(eventId).delete();
  }

  /// Get single event by ID
  Future<EventModel?> getEvent(String eventId) async {
    final doc = await _eventsRef.doc(eventId).get();
    if (!doc.exists) return null;
    return EventModel.fromFirestore(doc);
  }

  /// Stream a single event
  Stream<EventModel?> streamEvent(String eventId) {
    return _eventsRef.doc(eventId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return EventModel.fromFirestore(doc);
    });
  }

  /// Stream all events (real-time)
  Stream<List<EventModel>> streamAllEvents() {
    return _eventsRef
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromFirestore(doc))
            .toList());
  }

  /// Stream upcoming events
  Stream<List<EventModel>> streamUpcomingEvents({int limit = 10}) {
    return _eventsRef
        .where('date', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('date')
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromFirestore(doc))
            .toList());
  }

  /// Stream past events
  Stream<List<EventModel>> streamPastEvents({int limit = 20}) {
    return _eventsRef
        .where('date', isLessThan: Timestamp.now())
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromFirestore(doc))
            .toList());
  }

  /// Stream events by group
  Stream<List<EventModel>> streamEventsByGroup(String groupId) {
    return _eventsRef
        .where('groupId', isEqualTo: groupId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromFirestore(doc))
            .toList());
  }

  /// Get events for a specific date range (calendar)
  Stream<List<EventModel>> streamEventsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return _eventsRef
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromFirestore(doc))
            .toList());
  }

  /// Toggle participation
  Future<void> toggleParticipation(
    String eventId,
    String userId,
    ParticipationRole role,
  ) async {
    final eventDoc = await _eventsRef.doc(eventId).get();
    if (!eventDoc.exists) return;

    final event = EventModel.fromFirestore(eventDoc);

    switch (role) {
      case ParticipationRole.participant:
        if (event.participantIds.contains(userId)) {
          // Remove participation
          await _eventsRef.doc(eventId).update({
            'participantIds': FieldValue.arrayRemove([userId]),
            'participantCount': FieldValue.increment(-1),
            // Also remove from interested if was interested
            'interestedIds': FieldValue.arrayRemove([userId]),
          });
        } else {
          // Add participation
          await _eventsRef.doc(eventId).update({
            'participantIds': FieldValue.arrayUnion([userId]),
            'participantCount': FieldValue.increment(1),
            // Remove from interested
            'interestedIds': FieldValue.arrayRemove([userId]),
          });
          if (event.interestedIds.contains(userId)) {
            await _eventsRef.doc(eventId).update({
              'interestedCount': FieldValue.increment(-1),
            });
          }
        }
        break;

      case ParticipationRole.interested:
        if (event.interestedIds.contains(userId)) {
          await _eventsRef.doc(eventId).update({
            'interestedIds': FieldValue.arrayRemove([userId]),
            'interestedCount': FieldValue.increment(-1),
          });
        } else {
          await _eventsRef.doc(eventId).update({
            'interestedIds': FieldValue.arrayUnion([userId]),
            'interestedCount': FieldValue.increment(1),
          });
        }
        break;

      case ParticipationRole.organisateur:
        // Only admins can toggle organizer status
        if (event.organizerIds.contains(userId)) {
          await _eventsRef.doc(eventId).update({
            'organizerIds': FieldValue.arrayRemove([userId]),
          });
        } else {
          await _eventsRef.doc(eventId).update({
            'organizerIds': FieldValue.arrayUnion([userId]),
          });
        }
        break;
    }
  }

  /// Increment view count
  Future<void> incrementViewCount(String eventId) async {
    await _eventsRef.doc(eventId).update({
      'viewCount': FieldValue.increment(1),
    });
  }

  /// Get events count
  Future<int> getEventsCount() async {
    final snapshot = await _eventsRef.count().get();
    return snapshot.count ?? 0;
  }

  /// Get this week's events count
  Future<int> getThisWeekEventsCount() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final snapshot = await _eventsRef
        .where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
        .where('date', isLessThan: Timestamp.fromDate(endOfWeek))
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}
