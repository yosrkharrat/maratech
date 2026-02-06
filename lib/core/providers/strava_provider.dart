import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/media_model.dart';
import '../../services/strava_service.dart';
import '../../core/constants/enums.dart';

// Service provider
final stravaServiceProvider =
    Provider<StravaService>((ref) => StravaService());

// Classement for an event
final classementProvider =
    StreamProvider.family<List<ClassementEntry>, String>((ref, eventId) {
  return ref.read(stravaServiceProvider).streamClassement(eventId);
});

// Selected classement criteria
final classementCriteriaProvider =
    StateProvider<ClassementCriteria>((ref) => ClassementCriteria.distance);

// Strava activities cache
final stravaActivitiesProvider = StateProvider<List<Map<String, dynamic>>>(
  (ref) => [],
);
