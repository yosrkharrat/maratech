import 'package:cloud_firestore/cloud_firestore.dart';

/// Post model for the social feed
class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final String caption;
  final List<String> photoUrls;
  final String? location;
  final double? distance; // in km
  final int? duration; // in seconds
  final String? pace; // min/km
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.caption,
    required this.photoUrls,
    this.location,
    this.distance,
    this.duration,
    this.pace,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'] ?? '',
      caption: data['caption'] ?? '',
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      location: data['location'],
      distance: data['distance']?.toDouble(),
      duration: data['duration']?.toInt(),
      pace: data['pace'],
      likeCount: data['likeCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'caption': caption,
      'photoUrls': photoUrls,
      'location': location,
      'distance': distance,
      'duration': duration,
      'pace': pace,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String get formattedDistance {
    if (distance == null) return '';
    return '${distance!.toStringAsFixed(2)} km';
  }

  String get formattedDuration {
    if (duration == null) return '';
    final hours = duration! ~/ 3600;
    final minutes = (duration! % 3600) ~/ 60;
    final seconds = duration! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min ${seconds}s';
  }
}

/// Comment on a post
class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      postId: data['postId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'] ?? '',
      text: data['text'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

/// Like on a post
class LikeModel {
  final String id;
  final String postId;
  final String userId;
  final DateTime createdAt;

  LikeModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
  });

  factory LikeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LikeModel(
      id: doc.id,
      postId: data['postId'] ?? '',
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
