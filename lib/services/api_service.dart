import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

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
}