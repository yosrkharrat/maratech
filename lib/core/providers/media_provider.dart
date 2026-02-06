import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/media_model.dart';
import '../../services/media_service.dart';
import '../../core/constants/enums.dart';

// Service provider
final mediaServiceProvider =
    Provider<MediaService>((ref) => MediaService());

// Media for an event
final eventMediaProvider =
    StreamProvider.family<List<MediaModel>, String>((ref, eventId) {
  return ref.read(mediaServiceProvider).streamEventMedia(eventId);
});

// Photos only for an event
final eventPhotosProvider =
    StreamProvider.family<List<MediaModel>, String>((ref, eventId) {
  return ref
      .read(mediaServiceProvider)
      .streamEventMediaByType(eventId, MediaType.photo);
});

// Videos only for an event
final eventVideosProvider =
    StreamProvider.family<List<MediaModel>, String>((ref, eventId) {
  return ref
      .read(mediaServiceProvider)
      .streamEventMediaByType(eventId, MediaType.video);
});

// Notes for an event
final eventNotesProvider =
    StreamProvider.family<List<NoteModel>, String>((ref, eventId) {
  return ref.read(mediaServiceProvider).streamEventNotes(eventId);
});

// Comments for a parent (media/note)
final commentsProvider = StreamProvider.family<List<CommentModel>,
    ({String parentType, String parentId})>((ref, params) {
  return ref
      .read(mediaServiceProvider)
      .streamComments(params.parentType, params.parentId);
});

// Selected media tab (Photos / Videos / Reels)
final selectedMediaTabProvider = StateProvider<int>((ref) => 0);

// Selected media timing filter
final selectedTimingFilterProvider =
    StateProvider<MediaTiming?>((ref) => null);

// Upload progress
final uploadProgressProvider = StateProvider<double>((ref) => 0);
