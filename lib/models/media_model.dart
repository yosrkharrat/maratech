import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/enums.dart';

class MediaModel {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final MediaType type;
  final String url;
  final String? thumbnailUrl;
  final String caption;
  final String altText;
  final MediaTiming timing;
  final List<String> taggedUserIds;
  final int likesCount;
  final int commentsCount;
  final bool isPinned;
  final int? durationSeconds;
  final DateTime createdAt;

  const MediaModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.caption = '',
    this.altText = '',
    this.timing = MediaTiming.during,
    this.taggedUserIds = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isPinned = false,
    this.durationSeconds,
    required this.createdAt,
  });

  factory MediaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MediaModel(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'],
      type: MediaType.fromString(data['type'] ?? 'photo'),
      url: data['url'] ?? '',
      thumbnailUrl: data['thumbnailUrl'],
      caption: data['caption'] ?? '',
      altText: data['altText'] ?? '',
      timing: MediaTiming.fromString(data['timing'] ?? 'during'),
      taggedUserIds: List<String>.from(data['taggedUserIds'] ?? []),
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      isPinned: data['isPinned'] ?? false,
      durationSeconds: data['durationSeconds'],
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'type': type.value,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'caption': caption,
      'altText': altText,
      'timing': timing.value,
      'taggedUserIds': taggedUserIds,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'isPinned': isPinned,
      'durationSeconds': durationSeconds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  MediaModel copyWith({
    String? id,
    String? eventId,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    MediaType? type,
    String? url,
    String? thumbnailUrl,
    String? caption,
    String? altText,
    MediaTiming? timing,
    List<String>? taggedUserIds,
    int? likesCount,
    int? commentsCount,
    bool? isPinned,
    int? durationSeconds,
    DateTime? createdAt,
  }) {
    return MediaModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      type: type ?? this.type,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      caption: caption ?? this.caption,
      altText: altText ?? this.altText,
      timing: timing ?? this.timing,
      taggedUserIds: taggedUserIds ?? this.taggedUserIds,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isPinned: isPinned ?? this.isPinned,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class NoteModel {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String content;
  final NoteType type;
  final bool isPinned;
  final List<String> attachments;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;

  const NoteModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.content,
    this.type = NoteType.general,
    this.isPinned = false,
    this.attachments = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
  });

  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoteModel(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'],
      content: data['content'] ?? '',
      type: NoteType.fromString(data['type'] ?? 'general'),
      isPinned: data['isPinned'] ?? false,
      attachments: List<String>.from(data['attachments'] ?? []),
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'type': type.value,
      'isPinned': isPinned,
      'attachments': attachments,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class CommentModel {
  final String id;
  final String parentType;
  final String parentId;
  final String eventId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String content;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.parentType,
    required this.parentId,
    required this.eventId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      parentType: data['parentType'] ?? '',
      parentId: data['parentId'] ?? '',
      eventId: data['eventId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'],
      content: data['content'] ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'parentType': parentType,
      'parentId': parentId,
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class LikeModel {
  final String id;
  final String userId;
  final String likeableType;
  final String likeableId;
  final DateTime createdAt;

  const LikeModel({
    required this.id,
    required this.userId,
    required this.likeableType,
    required this.likeableId,
    required this.createdAt,
  });

  factory LikeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LikeModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      likeableType: data['likeableType'] ?? '',
      likeableId: data['likeableId'] ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'likeableType': likeableType,
      'likeableId': likeableId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class ClassementEntry {
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String? stravaActivityId;
  final double distance;
  final int movingTime;
  final String pace;
  final int rank;
  final DateTime? syncedAt;

  const ClassementEntry({
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    this.stravaActivityId,
    this.distance = 0,
    this.movingTime = 0,
    this.pace = '',
    this.rank = 0,
    this.syncedAt,
  });

  factory ClassementEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClassementEntry(
      userId: doc.id,
      userName: data['userName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'],
      stravaActivityId: data['stravaActivityId'],
      distance: (data['distance'] as num?)?.toDouble() ?? 0,
      movingTime: data['movingTime'] ?? 0,
      pace: data['pace'] ?? '',
      rank: data['rank'] ?? 0,
      syncedAt: (data['syncedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'stravaActivityId': stravaActivityId,
      'distance': distance,
      'movingTime': movingTime,
      'pace': pace,
      'rank': rank,
      'syncedAt':
          syncedAt != null ? Timestamp.fromDate(syncedAt!) : null,
    };
  }
}

class ProgramModel {
  final String id;
  final String title;
  final String description;
  final String coachId;
  final String coachName;
  final List<String> targetGroupIds;
  final List<ProgramWeek> weeks;
  final DateTime createdAt;

  const ProgramModel({
    required this.id,
    required this.title,
    required this.description,
    required this.coachId,
    required this.coachName,
    this.targetGroupIds = const [],
    this.weeks = const [],
    required this.createdAt,
  });

  factory ProgramModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProgramModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      coachId: data['coachId'] ?? '',
      coachName: data['coachName'] ?? '',
      targetGroupIds: List<String>.from(data['targetGroupIds'] ?? []),
      weeks: (data['weeks'] as List<dynamic>?)
              ?.map((w) => ProgramWeek.fromMap(w))
              .toList() ??
          [],
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'coachId': coachId,
      'coachName': coachName,
      'targetGroupIds': targetGroupIds,
      'weeks': weeks.map((w) => w.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class ProgramWeek {
  final int weekNumber;
  final String description;
  final List<ProgramSession> sessions;

  const ProgramWeek({
    required this.weekNumber,
    required this.description,
    this.sessions = const [],
  });

  factory ProgramWeek.fromMap(Map<String, dynamic> map) {
    return ProgramWeek(
      weekNumber: map['weekNumber'] ?? 0,
      description: map['description'] ?? '',
      sessions: (map['sessions'] as List<dynamic>?)
              ?.map((s) => ProgramSession.fromMap(s))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'weekNumber': weekNumber,
      'description': description,
      'sessions': sessions.map((s) => s.toMap()).toList(),
    };
  }
}

class ProgramSession {
  final String day;
  final String type;
  final String description;
  final double? distance;

  const ProgramSession({
    required this.day,
    required this.type,
    required this.description,
    this.distance,
  });

  factory ProgramSession.fromMap(Map<String, dynamic> map) {
    return ProgramSession(
      day: map['day'] ?? '',
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      distance: (map['distance'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'type': type,
      'description': description,
      'distance': distance,
    };
  }
}
