import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/providers/media_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/accessibility/a11y.dart';
import '../../core/constants/enums.dart';
import '../../models/media_model.dart';

class GalleryScreen extends ConsumerWidget {
  final String eventId;
  const GalleryScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = context.tr;
    final tab = ref.watch(selectedMediaTabProvider);
    final timing = ref.watch(selectedTimingFilterProvider);

    return DefaultTabController(
      length: 3,
      initialIndex: tab,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('gallery')),
          bottom: TabBar(
            onTap: (i) =>
                ref.read(selectedMediaTabProvider.notifier).state = i,
            tabs: [
              Tab(text: tr('all'), icon: const Icon(Icons.apps, size: 18)),
              Tab(text: tr('photos'), icon: const Icon(Icons.photo, size: 18)),
              Tab(text: tr('videos'), icon: const Icon(Icons.videocam, size: 18)),
            ],
          ),
          actions: [
            PopupMenuButton<MediaTiming>(
              icon: const Icon(Icons.filter_list),
              tooltip: tr('filter'),
              onSelected: (v) =>
                  ref.read(selectedTimingFilterProvider.notifier).state = v,
              itemBuilder: (_) => MediaTiming.values
                  .map((t) => PopupMenuItem(
                        value: t,
                        child: Row(
                          children: [
                            if (timing == t)
                              const Icon(Icons.check,
                                  size: 16, color: AppColors.primary),
                            if (timing == t) const SizedBox(width: 8),
                            Text(t.name),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _MediaGrid(eventId: eventId, type: null),
            _MediaGrid(eventId: eventId, type: MediaType.photo),
            _MediaGrid(eventId: eventId, type: MediaType.video),
          ],
        ),
      ),
    );
  }
}

class _MediaGrid extends ConsumerWidget {
  final String eventId;
  final MediaType? type;
  const _MediaGrid({required this.eventId, this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = context.tr;
    final AsyncValue<List<MediaModel>> mediaAsync;

    if (type == MediaType.photo) {
      mediaAsync = ref.watch(eventPhotosProvider(eventId));
    } else if (type == MediaType.video) {
      mediaAsync = ref.watch(eventVideosProvider(eventId));
    } else {
      mediaAsync = ref.watch(eventMediaProvider(eventId));
    }

    return mediaAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  type == MediaType.video
                      ? Icons.videocam_off
                      : Icons.photo_library,
                  size: 64,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(tr('no_media'),
                    style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: items.length,
          itemBuilder: (context, i) => _MediaTile(media: items[i]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
    );
  }
}

class _MediaTile extends StatelessWidget {
  final MediaModel media;
  const _MediaTile({required this.media});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: media.caption ?? (media.type == MediaType.photo ? 'Photo' : 'Video'),
      image: media.type == MediaType.photo,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail
            if (media.thumbnailUrl != null && media.thumbnailUrl!.isNotEmpty)
              Image.network(
                media.thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _PlaceholderTile(media: media),
              )
            else
              _PlaceholderTile(media: media),

            // Video icon overlay
            if (media.type == MediaType.video)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.play_arrow,
                      color: Colors.white, size: 16),
                ),
              ),

            // Pinned indicator
            if (media.isPinned)
              const Positioned(
                top: 4,
                left: 4,
                child: Icon(Icons.push_pin,
                    color: AppColors.secondary, size: 16),
              ),

            // Tap handler
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _showMediaDetail(context, media);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMediaDetail(BuildContext context, MediaModel media) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (media.url.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: media.type == MediaType.photo
                    ? Image.network(media.url, fit: BoxFit.contain)
                    : Container(
                        color: Colors.black,
                        child: const Center(
                          child: Icon(Icons.play_circle,
                              size: 64, color: Colors.white),
                        ),
                      ),
              ),
            if (media.caption != null && media.caption!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(media.caption!),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(context.tr('close')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderTile extends StatelessWidget {
  final MediaModel media;
  const _PlaceholderTile({required this.media});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Icon(
        media.type == MediaType.photo
            ? Icons.image
            : media.type == MediaType.video
                ? Icons.videocam
                : Icons.movie,
        color: AppColors.primary.withValues(alpha: 0.4),
        size: 32,
      ),
    );
  }
}
