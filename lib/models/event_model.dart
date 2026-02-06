import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/enums.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final EventType type;
  final EventStatus status;
  final DateTime date;
  final DateTime? endDate;
  final GeoPoint? location;
  final String locationName;
  final String? groupId;
  final double? distance;
  final int difficulty;
  final String? coverImageUrl;
  final List<String> organizerIds;
  final List<String> participantIds;
  final List<String> interestedIds;
  final int participantCount;
  final int interestedCount;
  final int viewCount;
  final bool stravaRequired;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.date,
    this.endDate,
    this.location,
    required this.locationName,
    this.groupId,
    this.distance,
    this.difficulty = 1,
    this.coverImageUrl,
    this.organizerIds = const [],
    this.participantIds = const [],
    this.interestedIds = const [],
    this.participantCount = 0,
    this.interestedCount = 0,
    this.viewCount = 0,
    this.stravaRequired = false,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: EventType.fromString(data['type'] ?? 'quotidien'),
      status: EventStatus.fromString(data['status'] ?? 'a_venir'),
      date: (data['date'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      location: data['location'] as GeoPoint?,
      locationName: data['locationName'] ?? '',
      groupId: data['groupId'],
      distance: (data['distance'] as num?)?.toDouble(),
      difficulty: data['difficulty'] ?? 1,
      coverImageUrl: data['coverImageUrl'],
      organizerIds: List<String>.from(data['organizerIds'] ?? []),
      participantIds: List<String>.from(data['participantIds'] ?? []),
      interestedIds: List<String>.from(data['interestedIds'] ?? []),
      participantCount: data['participantCount'] ?? 0,
      interestedCount: data['interestedCount'] ?? 0,
      viewCount: data['viewCount'] ?? 0,
      stravaRequired: data['stravaRequired'] ?? false,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'type': type.value,
      'status': status.value,
      'date': Timestamp.fromDate(date),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'location': location,
      'locationName': locationName,
      'groupId': groupId,
      'distance': distance,
      'difficulty': difficulty,
      'coverImageUrl': coverImageUrl,
      'organizerIds': organizerIds,
      'participantIds': participantIds,
      'interestedIds': interestedIds,
      'participantCount': participantCount,
      'interestedCount': interestedCount,
      'viewCount': viewCount,
      'stravaRequired': stravaRequired,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    EventType? type,
    EventStatus? status,
    DateTime? date,
    DateTime? endDate,
    GeoPoint? location,
    String? locationName,
    String? groupId,
    double? distance,
    int? difficulty,
    String? coverImageUrl,
    List<String>? organizerIds,
    List<String>? participantIds,
    List<String>? interestedIds,
    int? participantCount,
    int? interestedCount,
    int? viewCount,
    bool? stravaRequired,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      date: date ?? this.date,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      locationName: locationName ?? this.locationName,
      groupId: groupId ?? this.groupId,
      distance: distance ?? this.distance,
      difficulty: difficulty ?? this.difficulty,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      organizerIds: organizerIds ?? this.organizerIds,
      participantIds: participantIds ?? this.participantIds,
      interestedIds: interestedIds ?? this.interestedIds,
      participantCount: participantCount ?? this.participantCount,
      interestedCount: interestedCount ?? this.interestedCount,
      viewCount: viewCount ?? this.viewCount,
      stravaRequired: stravaRequired ?? this.stravaRequired,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  /// Compute dynamic status based on current time
  EventStatus get computedStatus {
    final now = DateTime.now();
    if (now.isBefore(date)) return EventStatus.upcoming;
    if (endDate != null && now.isAfter(endDate!)) return EventStatus.completed;
    if (now.isAfter(date) &&
        (endDate == null || now.isBefore(endDate!))) {
      return EventStatus.ongoing;
    }
    return EventStatus.completed;
  }

  bool isUserOrganizer(String userId) => organizerIds.contains(userId);
  bool isUserParticipant(String userId) => participantIds.contains(userId);
  bool isUserInterested(String userId) => interestedIds.contains(userId);
}
