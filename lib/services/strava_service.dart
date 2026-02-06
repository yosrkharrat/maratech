import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import '../core/constants/app_constants.dart';
import '../models/media_model.dart';

class StravaService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.stravaApiBase,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =================== OAUTH 2.0 ===================

  /// Initiate Strava OAuth flow
  Future<Map<String, dynamic>> authenticate() async {
    final authUrl = Uri.parse(
      '${AppConstants.stravaAuthUrl}'
      '?client_id=${AppConstants.stravaClientId}'
      '&redirect_uri=${AppConstants.stravaRedirectUri}'
      '&response_type=code'
      '&approval_prompt=auto'
      '&scope=read,activity:read_all',
    );

    // Open browser for OAuth
    final result = await FlutterWebAuth2.authenticate(
      url: authUrl.toString(),
      callbackUrlScheme: 'rctapp',
    );

    // Extract authorization code
    final code = Uri.parse(result).queryParameters['code'];
    if (code == null) {
      throw StravaException('Authorization code not received');
    }

    // Exchange code for tokens
    return await _exchangeCodeForToken(code);
  }

  /// Exchange authorization code for access token
  Future<Map<String, dynamic>> _exchangeCodeForToken(String code) async {
    try {
      final response = await Dio().post(
        AppConstants.stravaTokenUrl,
        data: {
          'client_id': AppConstants.stravaClientId,
          'client_secret': AppConstants.stravaClientSecret,
          'code': code,
          'grant_type': 'authorization_code',
        },
      );

      return {
        'access_token': response.data['access_token'],
        'refresh_token': response.data['refresh_token'],
        'expires_at': response.data['expires_at'],
        'athlete_id': response.data['athlete']['id'].toString(),
        'athlete_name':
            '${response.data['athlete']['firstname']} ${response.data['athlete']['lastname']}',
      };
    } catch (e) {
      throw StravaException('Failed to exchange token: ${e.toString()}');
    }
  }

  /// Refresh access token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await Dio().post(
        AppConstants.stravaTokenUrl,
        data: {
          'client_id': AppConstants.stravaClientId,
          'client_secret': AppConstants.stravaClientSecret,
          'refresh_token': refreshToken,
          'grant_type': 'refresh_token',
        },
      );

      return {
        'access_token': response.data['access_token'],
        'refresh_token': response.data['refresh_token'],
        'expires_at': response.data['expires_at'],
      };
    } catch (e) {
      throw StravaException('Failed to refresh token: ${e.toString()}');
    }
  }

  /// Save Strava tokens to Firestore
  Future<void> saveTokens(
    String userId,
    Map<String, dynamic> tokens,
  ) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({
      'stravaConnected': true,
      'stravaAthleteId': tokens['athlete_id'],
      'stravaTokens': {
        'access_token': tokens['access_token'],
        'refresh_token': tokens['refresh_token'],
        'expires_at': tokens['expires_at'],
      },
    });
  }

  /// Disconnect Strava
  Future<void> disconnect(String userId) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({
      'stravaConnected': false,
      'stravaAthleteId': null,
      'stravaTokens': null,
    });
  }

  /// Get valid access token (auto-refresh if expired)
  Future<String> getValidToken(String userId) async {
    final userDoc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .get();

    final tokens = userDoc.data()?['stravaTokens'] as Map<String, dynamic>?;
    if (tokens == null) {
      throw StravaException('Strava not connected');
    }

    final expiresAt = tokens['expires_at'] as int;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (now >= expiresAt) {
      // Token expired, refresh
      final newTokens = await refreshToken(tokens['refresh_token']);
      await saveTokens(userId, newTokens);
      return newTokens['access_token'];
    }

    return tokens['access_token'];
  }

  // =================== ACTIVITIES ===================

  /// Get recent activities
  Future<List<Map<String, dynamic>>> getRecentActivities(
    String accessToken, {
    int page = 1,
    int perPage = 30,
  }) async {
    try {
      final response = await _dio.get(
        '/athlete/activities',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw StravaException('Failed to fetch activities: ${e.toString()}');
    }
  }

  /// Get a specific activity with detailed data
  Future<Map<String, dynamic>> getActivity(
    String accessToken,
    String activityId,
  ) async {
    try {
      final response = await _dio.get(
        '/activities/$activityId',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw StravaException('Failed to fetch activity: ${e.toString()}');
    }
  }

  /// Get activity streams (GPS data)
  Future<Map<String, dynamic>> getActivityStreams(
    String accessToken,
    String activityId,
  ) async {
    try {
      final response = await _dio.get(
        '/activities/$activityId/streams',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
        queryParameters: {
          'keys': 'latlng,time,distance,altitude',
          'key_by_type': true,
        },
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw StravaException(
          'Failed to fetch activity streams: ${e.toString()}');
    }
  }

  // =================== CLASSEMENT ===================

  /// Link a Strava activity to an event and compute ranking
  Future<ClassementEntry> linkActivityToEvent({
    required String eventId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String activityId,
    required String accessToken,
  }) async {
    // Fetch activity details
    final activity = await getActivity(accessToken, activityId);

    final distance = (activity['distance'] as num).toDouble();
    final movingTime = activity['moving_time'] as int;
    final paceSeconds = movingTime / (distance / 1000);
    final paceMinutes = (paceSeconds / 60).floor();
    final paceRemainder = (paceSeconds % 60).floor();
    final pace =
        "$paceMinutes'${paceRemainder.toString().padLeft(2, '0')}";

    final entry = ClassementEntry(
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      stravaActivityId: activityId,
      distance: distance,
      movingTime: movingTime,
      pace: pace,
      rank: 0, // Will be computed
      syncedAt: DateTime.now(),
    );

    // Save to Firestore
    await _firestore
        .collection(AppConstants.eventsCollection)
        .doc(eventId)
        .collection('classement')
        .doc(userId)
        .set(entry.toFirestore());

    // Recompute rankings
    await _recomputeRankings(eventId);

    return entry;
  }

  /// Auto-match: Find Strava activities that match an event's time window
  Future<List<Map<String, dynamic>>> findMatchingActivities({
    required String accessToken,
    required DateTime eventDate,
    int windowMinutes = 120,
  }) async {
    final activities = await getRecentActivities(accessToken);

    return activities.where((activity) {
      final activityDate = DateTime.parse(activity['start_date']);
      final diff = activityDate.difference(eventDate).abs();
      return diff.inMinutes <= windowMinutes &&
          activity['type'] == 'Run';
    }).toList();
  }

  /// Get classement for an event
  Stream<List<ClassementEntry>> streamClassement(String eventId) {
    return _firestore
        .collection(AppConstants.eventsCollection)
        .doc(eventId)
        .collection('classement')
        .orderBy('rank')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClassementEntry.fromFirestore(doc))
            .toList());
  }

  /// Recompute rankings based on distance (default)
  Future<void> _recomputeRankings(String eventId) async {
    final snapshot = await _firestore
        .collection(AppConstants.eventsCollection)
        .doc(eventId)
        .collection('classement')
        .orderBy('distance', descending: true)
        .get();

    final batch = _firestore.batch();
    int rank = 1;

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'rank': rank});
      rank++;
    }

    await batch.commit();
  }

  /// Get athlete profile from Strava
  Future<Map<String, dynamic>> getAthleteProfile(
      String accessToken) async {
    try {
      final response = await _dio.get(
        '/athlete',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw StravaException(
          'Failed to fetch athlete profile: ${e.toString()}');
    }
  }
}

class StravaException implements Exception {
  final String message;
  const StravaException(this.message);

  @override
  String toString() => message;
}
