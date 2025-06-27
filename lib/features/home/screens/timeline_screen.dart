import 'package:flutter/material.dart';
import 'package:liteline_app/core/constants/app_text_styles.dart';
import 'package:liteline_app/features/home/widgets/timeline_post.dart';
import '../../../shared/widgets/empaty_state.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  // Dummy data for timeline posts
  final List<Map<String, dynamic>> _posts = [
    {
      'id': '1',
      'user_avatar': 'https://via.placeholder.com/150/FF0000/FFFFFF?text=User1',
      'user_name': 'Alice Wonderland',
      'post_time': DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
      'content': 'Enjoying a beautiful sunny day!',
      'image_url': 'https://via.placeholder.com/600x400/00B900/FFFFFF?text=Nature',
      'likes': 15,
      'comments': 3,
    },
    {
      'id': '2',
      'user_avatar': 'https://via.placeholder.com/150/0000FF/FFFFFF?text=User2',
      'user_name': 'Bob The Builder',
      'post_time': DateTime.now().subtract(const Duration(hours: 5)).millisecondsSinceEpoch,
      'content': 'Just finished a new project! Feeling accomplished.',
      'image_url': null,
      'likes': 20,
      'comments': 5,
    },
    {
      'id': '3',
      'user_avatar': 'https://via.placeholder.com/150/FFFF00/000000?text=User3',
      'user_name': 'Charlie Chaplin',
      'post_time': DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
      'content': 'Missing the old days. #throwback',
      'image_url': 'https://via.placeholder.com/600x400/FF5733/FFFFFF?text=OldTimes',
      'likes': 10,
      'comments': 2,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline', style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () {
              // TODO: Implement create new post
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create new post coming soon!')),
              );
            },
          ),
        ],
      ),
      body: _posts.isEmpty
          ? const EmptyState(
              icon: Icons.timeline,
              message: 'No posts yet. Start sharing your moments!',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return TimelinePost(
                  userAvatarUrl: post['user_avatar'],
                  userName: post['user_name'],
                  postTime: post['post_time'],
                  content: post['content'],
                  imageUrl: post['image_url'],
                  likesCount: post['likes'],
                  commentsCount: post['comments'],
                  onLike: () {
                    // TODO: Handle like action
                    print('Liked post ${post['id']}');
                  },
                  onComment: () {
                    // TODO: Handle comment action
                    print('Comment on post ${post['id']}');
                  },
                  onShare: () {
                    // TODO: Handle share action
                    print('Shared post ${post['id']}');
                  },
                );
              },
            ),
    );
  }
}