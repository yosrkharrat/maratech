import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/post_model.dart';
import '../../services/post_service.dart';
import '../../core/theme/app_colors.dart';

// Provider for posts feed
final postsFeedProvider = StreamProvider<List<PostModel>>((ref) {
  final postService = PostService();
  return postService.getFeedPosts(limit: 50);
});

// Provider for like state
final likeStateProvider = StreamProvider.family<bool, String>((ref, postId) {
  final currentUser = ref.watch(currentUserProvider).valueOrNull;
  if (currentUser == null) return Stream.value(false);
  final postService = PostService();
  return postService.isLikedStream(postId, currentUser.id);
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PostService _postService = PostService();

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final postsAsync = ref.watch(postsFeedProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              AppColors.primary.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // App Bar with gradient
            SliverAppBar(
              floating: true,
              snap: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondary, AppColors.secondaryDark],
                  ),
                ),
              ),
              title: Row(
                children: [
                  Icon(Icons.directions_run, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'RCT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              actions: [
                // Notifications
                IconButton(
                  icon: Icon(Icons.notifications_outlined, color: Colors.white),
                  onPressed: () => context.go('/notifications'),
                ),
              ],
            ),

            // Story-style quick access (upcoming events as stories)
            SliverToBoxAdapter(
              child: Container(
                height: 100,
                padding: EdgeInsets.symmetric(vertical: 12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Add your story
                      return _buildAddStoryButton();
                    }
                    return _buildStoryCircle(
                      name: 'Event ${index}',
                      imageUrl: 'https://via.placeholder.com/150',
                    );
                  },
                ),
              ),
            ),

            // Posts Feed
            postsAsync.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return SliverFillRemaining(
                    child: _buildEmptyState(),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = posts[index];
                      return _buildPostCard(post, currentUser);
                    },
                    childCount: posts.length,
                  ),
                );
              },
              loading: () => SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button to create post
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-post'),
        backgroundColor: AppColors.secondary,
        icon: Icon(Icons.add_a_photo, color: Colors.white),
        label: Text('Partager', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 4,
      ),
    );
  }

  Widget _buildAddStoryButton() {
    return GestureDetector(
      onTap: () => context.push('/create-post'),
      child: Container(
        margin: EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.secondary, AppColors.secondaryLight],
                ),
              ),
              child: Icon(Icons.add, color: Colors.white, size: 32),
            ),
            SizedBox(height: 4),
            Text(
              'Ajouter',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCircle({required String name, required String imageUrl}) {
    return Container(
      margin: EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.secondary, AppColors.secondaryLight],
              ),
              border: Border.all(color: Colors.white, width: 3),
            ),
            padding: EdgeInsets.all(3),
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(imageUrl),
            ),
          ),
          SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(PostModel post, dynamic currentUser) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header (user info)
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 20,
              backgroundImage: post.userPhotoUrl.isNotEmpty
                  ? CachedNetworkImageProvider(post.userPhotoUrl)
                  : null,
              child: post.userPhotoUrl.isEmpty
                  ? Icon(Icons.person, size: 24)
                  : null,
            ),
            title: Text(
              post.userName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Text(
              timeago.format(post.createdAt, locale: 'fr'),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () => _showPostOptions(post, currentUser),
            ),
          ),

          // Post Image(s)
          if (post.photoUrls.isNotEmpty)
            AspectRatio(
              aspectRatio: 1,
              child: post.photoUrls.length == 1
                  ? CachedNetworkImage(
                      imageUrl: post.photoUrls[0],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  : PageView.builder(
                      itemCount: post.photoUrls.length,
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                          imageUrl: post.photoUrls[index],
                          fit: BoxFit.cover,
                        );
                      },
                    ),
            ),

          // Action Buttons (Like, Comment)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                _buildLikeButton(post.id, currentUser),
                SizedBox(width: 16),
                _buildCommentButton(post),
                SizedBox(width: 16),
                Icon(Icons.share_outlined, size: 26),
                Spacer(),
                if (post.location != null)
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: AppColors.secondary),
                      Text(
                        post.location!,
                        style: TextStyle(fontSize: 12, color: AppColors.secondary),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Likes Count
          if (post.likeCount > 0)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${post.likeCount} ${post.likeCount == 1 ? 'j\'aime' : 'j\'aimes'}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),

          // Running Stats
          if (post.distance != null || post.duration != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (post.distance != null)
                      _buildStatItem(
                        Icons.straighten,
                        post.formattedDistance,
                        'Distance',
                      ),
                    if (post.duration != null)
                      _buildStatItem(
                        Icons.timer_outlined,
                        post.formattedDuration,
                        'Durée',
                      ),
                    if (post.pace != null)
                      _buildStatItem(
                        Icons.speed,
                        '${post.pace} /km',
                        'Allure',
                      ),
                  ],
                ),
              ),
            ),

          // Caption
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black87, fontSize: 14),
                children: [
                  TextSpan(
                    text: '${post.userName} ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: post.caption),
                ],
              ),
            ),
          ),

          // View Comments
          if (post.commentCount > 0)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: GestureDetector(
                onTap: () => _showComments(post),
                child: Text(
                  'Voir les ${post.commentCount} commentaire${post.commentCount > 1 ? 's' : ''}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            ),

          SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildLikeButton(String postId, dynamic currentUser) {
    if (currentUser == null) {
      return Icon(Icons.favorite_border, size: 26);
    }

    final isLikedAsync = ref.watch(likeStateProvider(postId));

    return isLikedAsync.when(
      data: (isLiked) => GestureDetector(
        onTap: () async {
          if (isLiked) {
            await _postService.unlikePost(postId, currentUser.id);
          } else {
            await _postService.likePost(postId, currentUser.id);
          }
        },
        child: Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          size: 26,
          color: isLiked ? Colors.red : null,
        ),
      ),
      loading: () => Icon(Icons.favorite_border, size: 26),
      error: (_, __) => Icon(Icons.favorite_border, size: 26),
    );
  }

  Widget _buildCommentButton(PostModel post) {
    return GestureDetector(
      onTap: () => _showComments(post),
      child: Icon(Icons.chat_bubble_outline, size: 26),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.secondary, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.secondaryDark,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_camera_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Aucune publication',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Partagez votre première course !',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/create-post'),
            icon: Icon(Icons.add_a_photo),
            label: Text('Créer une publication'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showPostOptions(PostModel post, dynamic currentUser) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (currentUser?.id == post.userId)
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Supprimer', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(context);
                    await _postService.deletePost(post.id);
                  },
                ),
              ListTile(
                leading: Icon(Icons.report),
                title: Text('Signaler'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Report post
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Annuler'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showComments(PostModel post) {
    // TODO: Navigate to comments screen or show bottom sheet
    context.push('/post/${post.id}/comments');
  }
}
