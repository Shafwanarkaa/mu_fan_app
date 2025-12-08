import 'package:flutter/material.dart';
import '../data/mock_data.dart';

class ForumProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _posts = [];

  ForumProvider() {
    _posts = List.from(MockData.initialForumPosts);
  }

  List<Map<String, dynamic>> get posts => _posts;

  void addPost(String author, String content) {
    final newPost = {
      'id': DateTime.now().toString(),
      'author': author,
      'content': content,
      'likes': 0,
      'date': DateTime.now().toString().substring(0, 16),
    };
    _posts.insert(0, newPost);
    notifyListeners();
  }

  void deletePost(String id) {
    _posts.removeWhere((post) => post['id'] == id);
    notifyListeners();
  }
}
