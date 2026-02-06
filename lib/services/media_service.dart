import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/media_model.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/enums.dart';

class MediaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  // =================== MEDIA CRUD ===================

  /// Upload a photo/video to Firebase Storage and create Firestore record
  Future<MediaModel> uploadMedia({
    required String eventId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required File file,
    required MediaType type,
    required String caption,
    required String altText,
    required MediaTiming timing,
    List<String> taggedUserIds = const [],
  }) async {
    // Generate unique filename
    final extension = file.path.split('.').last;
    final fileName = '${_uuid.v4()}.$extension';
    final storagePath =
        '${AppConstants.eventMediaPath}/$eventId/$userId/$fileName';

    // Upload to Firebase Storage
    final ref = _storage.ref(storagePath);
    final metadata = SettableMetadata(
      contentType: type == MediaType.photo
          ? 'image/$extension'
          : 'video/$extension',
      customMetadata: {
        'eventId': eventId,
        'userId': userId,
        'type': type.value,
      },
    );

    await ref.putFile(file, metadata);
    final downloadUrl = await ref.getDownloadURL();

    // Generate thumbnail URL (handled by Cloud Function in production)
    String? thumbnailUrl;
    if (type == MediaType.photo) {
      thumbnailUrl = downloadUrl; // Use same URL; Cloud Function will create thumbnail
    }

    // Create Firestore record
    final media = MediaModel(
      id: '',
      eventId: eventId,
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      type: type,
      url: downloadUrl,
      thumbnailUrl: thumbnailUrl,
      caption: caption,
      altText: altText,
      timing: timing,
      taggedUserIds: taggedUserIds,
      createdAt: DateTime.now(),
    );

    final docRef = await _firestore
        .collection(AppConstants.eventsCollection)
        .doc(eventId)
        .collection('media')
        .add(media.toFirestore());

    return media.copyWith(id: docRef.id);
  }

  /// Get all media for an event
  Stream<List<MediaModel>> streamEventMedia(String eventId) {
    return _firestore
        .collection(AppConstants.eventsCollection)
        .doc(eventId)
        .collection('media')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MediaModel.fromFirestore(doc))
            .toList());
  }

  /// Get media filtered by type
  Stream<List<MediaModel>> streamEventMediaByType(
    String eventId,
    MediaType type,
  ) {
    return _firestore
        .collection(AppConstants.eventsCollection)
        .doc(eventId)
        .collection('media')
        .where('type', isEqualTo: type.value)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MediaModel.fromFirestore(doc))
            .toList());
  }

  /// Get media filtered by timing
  Stream<List<MediaModel>> streamEventMediaByTiming(
    String eventId,
    MediaTiming timing,
  ) {
    return _firestore
        .collection(AppConstants.eventsCollection)
        .doc(eventId)
        .collection('media')
        .where('timing', isEqualTo: timing.value)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MediaModel.fromFirestore(doc))
            .toList());
  }

  /// Delete media
  Future<void> deleteMedia(String eventId, String mediaId,
      String storageUrl) async {
    // Delete from Storage
    try {
      await _storage.refFromURL(storageUrl).delete();
    } catch (_) {
      // Storage file may already be deleted
    }

    // Delete from Firestore
    await _firestore
        .collection(AppConstants.eventsCollection)
        .doc(eventId)
        .collection('media')
        .doc(mediaId)
        .delete();
  }

  /// Toggle pin status (admin only)
  Future<void> togglePin(String eventId, String mediaId, bool isPinned) async {
    await _firestore
        .collection(AppConstants.eventsCollection)
        .doc(eventId)
        .collection('media')
        .doc(mediaId)
        .update({'isPinned': !isPinned});
  }

  // =================== NOTES ===================

  /// Add a note to an event
  Future<NoteModel> addNote({
    required String eventId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String content,
    required NoteType type,
    List<String> attachments = const [],
    bool isPinned = false,
  }) async {
    final note = NoteModel(
      id: '',
      eventId: eventId,
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      content: content,
      type: type,
      isPinned: isPinned,
      attachments: attachments,
      createdAt: DateTime.now(),
    );

    final docRef = await _firestore
        .collection(AppConstants.eventsCollection)
        .doc(eventId)
        .collection('notes')
        .add(note.toFirestore());

    return NoteModel(
      id: docRef.id,
      eventId: eventId,
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      content: content,
      type: type,
      isPinned: isPinned,
      attachments: attachments,
      createdAt: DateTime.now(),
    );
  }

  /// Stream notes for an event
  Stream<List<NoteModel>> streamEventNotes(String eventId) {
    return _firestore
        .collection(AppConstants.eventsCollection)
        .doc(eventId)
        .collection('notes')
        .orderBy('isPinned', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NoteModel.fromFirestore(doc))
            .toList());
  }

  /// Delete note
  Future<void> deleteNote(String eventId, String noteId) async {
    await _firestore
        .collection(AppConstants.eventsCollection)
        .doc(eventId)
        .collection('notes')
        .doc(noteId)
        .delete();
  }

  // =================== COMMENTS ===================

  /// Add a comment
  Future<CommentModel> addComment({
    required String parentType,
    required String parentId,
    required String eventId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String content,
  }) async {
    final comment = CommentModel(
      id: '',
      parentType: parentType,
      parentId: parentId,
      eventId: eventId,
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      content: content,
      createdAt: DateTime.now(),
    );

    final docRef = await _firestore
        .collection(AppConstants.commentsCollection)
        .add(comment.toFirestore());

    // Increment comment count on parent
    if (parentType == 'media') {
      await _firestore
          .collection(AppConstants.eventsCollection)
          .doc(eventId)
          .collection('media')
          .doc(parentId)
          .update({'commentsCount': FieldValue.increment(1)});
    } else if (parentType == 'note') {
      await _firestore
          .collection(AppConstants.eventsCollection)
          .doc(eventId)
          .collection('notes')
          .doc(parentId)
          .update({'commentsCount': FieldValue.increment(1)});
    }

    return CommentModel(
      id: docRef.id,
      parentType: parentType,
      parentId: parentId,
      eventId: eventId,
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      content: content,
      createdAt: DateTime.now(),
    );
  }

  /// Stream comments for a parent (media or note)
  Stream<List<CommentModel>> streamComments(
      String parentType, String parentId) {
    return _firestore
        .collection(AppConstants.commentsCollection)
        .where('parentType', isEqualTo: parentType)
        .where('parentId', isEqualTo: parentId)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromFirestore(doc))
            .toList());
  }

  // =================== LIKES ===================

  /// Toggle like
  Future<bool> toggleLike({
    required String userId,
    required String likeableType,
    required String likeableId,
    required String eventId,
  }) async {
    final query = await _firestore
        .collection(AppConstants.likesCollection)
        .where('userId', isEqualTo: userId)
        .where('likeableType', isEqualTo: likeableType)
        .where('likeableId', isEqualTo: likeableId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      // Unlike
      await query.docs.first.reference.delete();
      await _updateLikeCount(likeableType, likeableId, eventId, -1);
      return false;
    } else {
      // Like
      final like = LikeModel(
        id: '',
        userId: userId,
        likeableType: likeableType,
        likeableId: likeableId,
        createdAt: DateTime.now(),
      );
      await _firestore
          .collection(AppConstants.likesCollection)
          .add(like.toFirestore());
      await _updateLikeCount(likeableType, likeableId, eventId, 1);
      return true;
    }
  }

  /// Check if user has liked
  Future<bool> hasUserLiked(
      String userId, String likeableType, String likeableId) async {
    final query = await _firestore
        .collection(AppConstants.likesCollection)
        .where('userId', isEqualTo: userId)
        .where('likeableType', isEqualTo: likeableType)
        .where('likeableId', isEqualTo: likeableId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<void> _updateLikeCount(
    String type,
    String id,
    String eventId,
    int increment,
  ) async {
    if (type == 'media') {
      await _firestore
          .collection(AppConstants.eventsCollection)
          .doc(eventId)
          .collection('media')
          .doc(id)
          .update({'likesCount': FieldValue.increment(increment)});
    } else if (type == 'note') {
      await _firestore
          .collection(AppConstants.eventsCollection)
          .doc(eventId)
          .collection('notes')
          .doc(id)
          .update({'likesCount': FieldValue.increment(increment)});
    }
  }
}
