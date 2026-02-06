import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../services/post_service.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final PostService _postService = PostService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _paceController = TextEditingController();

  List<File> _selectedImages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    _distanceController.dispose();
    _durationController.dispose();
    _paceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages = images.map((image) => File(image.path)).toList();
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }

  Future<void> _createPost() async {
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vous devez être connecté')),
      );
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ajoutez au moins une photo')),
      );
      return;
    }

    if (_captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ajoutez une description')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Parse duration if provided (format: HH:MM:SS or MM:SS)
      int? duration;
      if (_durationController.text.isNotEmpty) {
        final parts = _durationController.text.split(':').map(int.parse).toList();
        if (parts.length == 3) {
          duration = parts[0] * 3600 + parts[1] * 60 + parts[2];
        } else if (parts.length == 2) {
          duration = parts[0] * 60 + parts[1];
        }
      }

      await _postService.createPost(
        userId: currentUser.id,
        userName: currentUser.displayName,
        userPhotoUrl: currentUser.profilePhotoUrl ?? '',
        caption: _captionController.text.trim(),
        photos: _selectedImages,
        location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
        distance: _distanceController.text.isNotEmpty ? double.tryParse(_distanceController.text) : null,
        duration: duration,
        pace: _paceController.text.trim().isNotEmpty ? _paceController.text.trim() : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Publication créée avec succès !')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nouvelle publication'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.secondary, AppColors.secondaryDark],
            ),
          ),
        ),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _createPost,
              child: Text(
                'Publier',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo Selection
            if (_selectedImages.isEmpty)
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.secondary, width: 2, style: BorderStyle.solid),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size: 64, color: AppColors.secondary),
                        SizedBox(height: 12),
                        Text(
                          'Ajouter des photos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Appuyez pour sélectionner',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  Container(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _selectedImages.length) {
                          return GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              width: 150,
                              margin: EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.add, size: 48, color: AppColors.secondary),
                            ),
                          );
                        }

                        return Container(
                          width: 200,
                          margin: EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImages[index],
                                  fit: BoxFit.cover,
                                  width: 200,
                                  height: 250,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImages.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.close, color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  // Camera button
                  OutlinedButton.icon(
                    onPressed: _takePhoto,
                    icon: Icon(Icons.camera_alt),
                    label: Text('Prendre une photo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: BorderSide(color: AppColors.secondary),
                    ),
                  ),
                ],
              ),

            SizedBox(height: 24),

            // Caption
            TextField(
              controller: _captionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Partagez votre expérience...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.secondary, width: 2),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Location
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Lieu (optionnel)',
                hintText: 'Parc, ville...',
                prefixIcon: Icon(Icons.location_on, color: AppColors.secondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.secondary, width: 2),
                ),
              ),
            ),

            SizedBox(height: 24),

            // Running Stats Section
            Text(
              'Statistiques de course (optionnel)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryDark,
              ),
            ),
            SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _distanceController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Distance (km)',
                      prefixIcon: Icon(Icons.straighten, color: AppColors.secondary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.secondary, width: 2),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Durée (HH:MM:SS)',
                      hintText: '01:30:00',
                      prefixIcon: Icon(Icons.timer, color: AppColors.secondary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.secondary, width: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            TextField(
              controller: _paceController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Allure (min/km)',
                hintText: '5:30',
                prefixIcon: Icon(Icons.speed, color: AppColors.secondary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.secondary, width: 2),
                ),
              ),
            ),

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
