import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/media_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/accessibility/a11y.dart';
import '../../core/constants/enums.dart';
import '../../services/media_service.dart';

class UploadMediaScreen extends ConsumerStatefulWidget {
  final String eventId;
  const UploadMediaScreen({super.key, required this.eventId});

  @override
  ConsumerState<UploadMediaScreen> createState() => _UploadMediaScreenState();
}

class _UploadMediaScreenState extends ConsumerState<UploadMediaScreen> {
  final _captionCtrl = TextEditingController();
  final _picker = ImagePicker();

  MediaType _type = MediaType.photo;
  MediaTiming _timing = MediaTiming.during;
  XFile? _file;
  bool _isUploading = false;

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    XFile? picked;
    if (_type == MediaType.photo) {
      picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
      );
    } else {
      picked = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
      );
    }
    if (picked != null) {
      setState(() => _file = picked);
    }
  }

  Future<void> _takePhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _file = picked;
        _type = MediaType.photo;
      });
    }
  }

  Future<void> _upload() async {
    if (_file == null) return;
    setState(() => _isUploading = true);

    try {
      final userAsync = ref.read(currentUserProvider);
      final user = userAsync.valueOrNull;
      if (user == null) throw Exception('Not authenticated');

      final service = ref.read(mediaServiceProvider);
      await service.uploadMedia(
        eventId: widget.eventId,
        file: File(_file!.path),
        type: _type,
        timing: _timing,
        userId: user.id,
        userName: user.displayName,
        caption: _captionCtrl.text.trim().isNotEmpty
            ? _captionCtrl.text.trim()
            : '',
        altText: '',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('upload_success'))),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return Scaffold(
      appBar: AppBar(title: Text(tr('upload'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Type selector
            Text(tr('media_type'),
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SegmentedButton<MediaType>(
              segments: [
                ButtonSegment(
                  value: MediaType.photo,
                  icon: const Icon(Icons.photo),
                  label: Text(tr('photos')),
                ),
                ButtonSegment(
                  value: MediaType.video,
                  icon: const Icon(Icons.videocam),
                  label: Text(tr('videos')),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) =>
                  setState(() => _type = s.first),
            ),
            const SizedBox(height: 20),

            // Timing selector
            Text(tr('timing'),
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SegmentedButton<MediaTiming>(
              segments: [
                ButtonSegment(
                  value: MediaTiming.before,
                  label: Text(tr('before')),
                ),
                ButtonSegment(
                  value: MediaTiming.during,
                  label: Text(tr('during')),
                ),
                ButtonSegment(
                  value: MediaTiming.after,
                  label: Text(tr('after')),
                ),
              ],
              selected: {_timing},
              onSelectionChanged: (s) =>
                  setState(() => _timing = s.first),
            ),
            const SizedBox(height: 24),

            // Preview / Pick
            if (_file != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _type == MediaType.photo
                        ? Image.file(
                            File(_file!.path),
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 250,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.videocam,
                                    size: 48, color: Colors.white54),
                                const SizedBox(height: 8),
                                Text(
                                  _file!.name,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton.filledTonal(
                      onPressed: () => setState(() => _file = null),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.3),
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _pickMedia,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _type == MediaType.photo
                            ? Icons.add_photo_alternate
                            : Icons.video_call,
                        size: 48,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(tr('tap_to_select'),
                          style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Pick actions
            Row(
              children: [
                Expanded(
                  child: A11y.touchTarget(
                    child: OutlinedButton.icon(
                      onPressed: _pickMedia,
                      icon: const Icon(Icons.photo_library),
                      label: Text(tr('gallery')),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: A11y.touchTarget(
                    child: OutlinedButton.icon(
                      onPressed: _takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: Text(tr('camera')),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Caption
            TextFormField(
              controller: _captionCtrl,
              decoration: InputDecoration(
                labelText: tr('caption'),
                prefixIcon: const Icon(Icons.short_text),
              ),
              maxLines: 2,
              maxLength: 200,
            ),
            const SizedBox(height: 24),

            // Upload button
            A11y.touchTarget(
              child: FilledButton.icon(
                onPressed:
                    (_file != null && !_isUploading) ? _upload : null,
                icon: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(_isUploading ? tr('uploading') : tr('upload')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
