import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/post_model.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ── POSTS ──

  /// Create a new post
  Future<String> createPost({
    required String userId,
    required String userName,
    required String userPhotoUrl,
    required String caption,
    required List<File> photos,
    String? location,
    double? distance,
    int? duration,
    String? pace,
  }) async {
    try {
      // Upload photos
      List<String> photoUrls = [];
      for (int i = 0; i < photos.length; i++) {
        final ref = _storage.ref().child('posts/$userId/${DateTime.now().millisecondsSinceEpoch}_$i.jpg');
        await ref.putFile(photos[i]);
        final url = await ref.getDownloadURL();
        photoUrls.add(url);
      }

      // Create post
      final post = PostModel(
        id: '',
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        caption: caption,
        photoUrls: photoUrls,
        location: location,
        distance: distance,
        duration: duration,
        pace: pace,
        likeCount: 0,
        commentCount: 0,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore.collection('posts').add(post.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  /// Get feed posts (ordered by createdAt desc)
  Stream<List<PostModel>> getFeedPosts({int limit = 20}) {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList());
  }

  /// Get posts by user
  Stream<List<PostModel>> getUserPosts(String userId) {
    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList());
  }

  /// Delete post
  Future<void> deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
    // Also delete associated likes and comments
    final likes = await _firestore.collection('likes').where('postId', isEqualTo: postId).get();
    for (var doc in likes.docs) {
      await doc.reference.delete();
    }
    final comments = await _firestore.collection('comments').where('postId', isEqualTo: postId).get();
    for (var doc in comments.docs) {
      await doc.reference.delete();
    }
  }

  // ── LIKES ──

  /// Like a post
  Future<void> likePost(String postId, String userId) async {
    final batch = _firestore.batch();

    // Add like
    final likeRef = _firestore.collection('likes').doc('${postId}_$userId');
    batch.set(likeRef, {
      'postId': postId,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Increment like count
    final postRef = _firestore.collection('posts').doc(postId);
    batch.update(postRef, {'likeCount': FieldValue.increment(1)});

    await batch.commit();
  }

  /// Unlike a post
  Future<void> unlikePost(String postId, String userId) async {
    final batch = _firestore.batch();

    // Remove like
    final likeRef = _firestore.collection('likes').doc('${postId}_$userId');
    batch.delete(likeRef);

    // Decrement like count
    final postRef = _firestore.collection('posts').doc(postId);
    batch.update(postRef, {'likeCount': FieldValue.increment(-1)});

    await batch.commit();
  }

  /// Check if user liked a post
  Future<bool> hasLiked(String postId, String userId) async {
    final doc = await _firestore.collection('likes').doc('${postId}_$userId').get();
    return doc.exists;
  }

  /// Stream to check if user liked a post
  Stream<bool> isLikedStream(String postId, String userId) {
    return _firestore.collection('likes').doc('${postId}_$userId').snapshots().map((doc) => doc.exists);
  }

  // ── COMMENTS ──

  /// Add comment to post
  Future<void> addComment({
    required String postId,
    required String userId,
    required String userName,
    required String userPhotoUrl,
    required String text,
  }) async {
    final batch = _firestore.batch();

    // Add comment
    final commentRef = _firestore.collection('comments').doc();
    batch.set(commentRef, {
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Increment comment count
    final postRef = _firestore.collection('posts').doc(postId);
    batch.update(postRef, {'commentCount': FieldValue.increment(1)});

    await batch.commit();
  }

  /// Get comments for a post
  Stream<List<CommentModel>> getComments(String postId) {
    return _firestore
        .collection('comments')
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => CommentModel.fromFirestore(doc)).toList());
  }

  /// Delete comment
  Future<void> deleteComment(String postId, String commentId) async {
    final batch = _firestore.batch();

    // Delete comment
    final commentRef = _firestore.collection('comments').doc(commentId);
    batch.delete(commentRef);

    // Decrement comment count
    final postRef = _firestore.collection('posts').doc(postId);
    batch.update(postRef, {'commentCount': FieldValue.increment(-1)});

    await batch.commit();
  }
}
