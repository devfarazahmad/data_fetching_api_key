import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../repositories/post_repository.dart';

class PostProvider with ChangeNotifier {
  final PostRepository _postRepository = PostRepository();
  
  // Post state
  List<Post> _posts = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _usingLocalData = false;

  // Comment state
  List<Comment> _comments = [];
  bool _isLoadingComments = false;
  String _commentsErrorMessage = '';
  Map<int, List<Comment>> _postComments = {};

  // Getters for posts
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get usingLocalData => _usingLocalData;

  // Getters for comments
  List<Comment> get comments => _comments;
  bool get isLoadingComments => _isLoadingComments;
  String get commentsErrorMessage => _commentsErrorMessage;
  List<Comment> getCommentsForPost(int postId) => _postComments[postId] ?? [];

  // Load all posts
  Future<void> loadPosts() async {
    _setLoading(true);
    _errorMessage = '';
    _usingLocalData = false;
    notifyListeners();

    try {
      final posts = await _postRepository.getAllPosts();
      _posts = posts;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to load posts: $e';
      _usingLocalData = true;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Get single post by ID
  Future<Post> getPost(int id) async {
    try {
      return await _postRepository.getPost(id);
    } catch (e) {
      return Post(userId: 0, id: 0, title: 'Not Found', body: 'Post not found');
    }
  }

  // Create new post
  Future<void> createPost(Post post) async {
    _setLoading(true);
    notifyListeners();

    try {
      final newPost = await _postRepository.createPost(post);
      _posts.insert(0, newPost); // Add at beginning of list
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to create post: $e';
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Update post
  Future<void> updatePost(Post post) async {
    _setLoading(true);
    notifyListeners();

    try {
      final updatedPost = await _postRepository.updatePost(post);
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _posts[index] = updatedPost;
      }
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to update post: $e';
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Delete post
  Future<void> deletePost(int id) async {
    _setLoading(true);
    notifyListeners();

    try {
      final success = await _postRepository.deletePost(id);
      if (success) {
        _posts.removeWhere((post) => post.id == id);
        // Also remove any cached comments for this post
        _postComments.remove(id);
      }
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to delete post: $e';
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Load comments for a specific post
  Future<void> loadCommentsForPost(int postId) async {
    _setLoadingComments(true);
    _commentsErrorMessage = '';
    notifyListeners();

    try {
      final comments = await _postRepository.getCommentsByPostId(postId);
      _postComments[postId] = comments;
      _commentsErrorMessage = '';
    } catch (e) {
      _commentsErrorMessage = 'Failed to load comments: $e';
    } finally {
      _setLoadingComments(false);
      notifyListeners();
    }
  }

  // Load all comments
  Future<void> loadAllComments() async {
    _setLoadingComments(true);
    _commentsErrorMessage = '';
    notifyListeners();

    try {
      final comments = await _postRepository.getAllComments();
      _comments = comments;
      _commentsErrorMessage = '';
    } catch (e) {
      _commentsErrorMessage = 'Failed to load comments: $e';
    } finally {
      _setLoadingComments(false);
      notifyListeners();
    }
  }

  // Refresh posts
  Future<void> refreshPosts() async {
    await loadPosts();
  }

  // Clear error message
  void clearError() {
    _errorMessage = '';
    _usingLocalData = false;
    notifyListeners();
  }

  // Clear comments error message
  void clearCommentsError() {
    _commentsErrorMessage = '';
    notifyListeners();
  }

  // Private method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Private method to set comments loading state
  void _setLoadingComments(bool loading) {
    _isLoadingComments = loading;
    notifyListeners();
  }
}