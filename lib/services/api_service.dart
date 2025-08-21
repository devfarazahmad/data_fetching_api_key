import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/comment.dart'; // Add this import

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  // Existing post methods...
  Future<List<Post>> getPosts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load posts. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load posts: $e');
    }
  }

  Future<Post> getPostById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        return Post.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load post. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load post: $e');
    }
  }

  // NEW: Method to fetch comments for a post
  Future<List<Comment>> getCommentsByPostId(int postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/comments?postId=$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Comment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load comments. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load comments: $e');
    }
  }

  // NEW: Method to fetch all comments
  Future<List<Comment>> getAllComments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/comments'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Comment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load comments. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load comments: $e');
    }
  }
}