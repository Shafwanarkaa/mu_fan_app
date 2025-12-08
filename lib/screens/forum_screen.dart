import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/forum_provider.dart';
import '../theme/app_theme.dart';

class ForumScreen extends StatelessWidget {
  const ForumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAN FORUM')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPostDialog(context),
        backgroundColor: AppTheme.muRed,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<ForumProvider>(
        builder: (context, forumProvider, child) {
          if (forumProvider.posts.isEmpty) {
            return const Center(child: Text('No posts yet. Be the first!'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: forumProvider.posts.length,
            itemBuilder: (context, index) {
              final post = forumProvider.posts[index];
              return FadeInUp(
                duration: const Duration(milliseconds: 300),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppTheme.muRed,
                                  child: Text(
                                    post['author'][0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post['author'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.muGold,
                                      ),
                                    ),
                                    Text(
                                      post['date'],
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.grey),
                              onPressed: () {
                                forumProvider.deletePost(post['id']);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(post['content']),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('${post['likes']} Likes', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddPostDialog(BuildContext context) {
    final authorController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: authorController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'Message'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (authorController.text.isNotEmpty && contentController.text.isNotEmpty) {
                Provider.of<ForumProvider>(context, listen: false)
                    .addPost(authorController.text, contentController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }
}
