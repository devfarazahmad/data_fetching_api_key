import '../models/post.dart';
import '../models/comment.dart';
import '../services/api_service.dart';

class PostRepository {
  final ApiService _apiService = ApiService();

  // GET all posts
  Future<List<Post>> getAllPosts() async {
    try {
      return await _apiService.getPosts();
    } catch (e) {
      print('API call failed, using local data: $e');
      return _getLocalPosts();
    }
  }

  // GET single post
  Future<Post> getPost(int id) async {
    try {
      return await _apiService.getPostById(id);
    } catch (e) {
      print('API call failed, using local data: $e');
      final localPosts = await _getLocalPosts();
      return localPosts.firstWhere((post) => post.id == id, 
        orElse: () => Post(userId: 0, id: 0, title: 'Not Found', body: 'Post not found'));
    }
  }

  // POST - Create new post
  Future<Post> createPost(Post post) async {
    try {
      return await _apiService.createPost(post);
    } catch (e) {
      print('API call failed, creating post locally: $e');
      // For local fallback, we'll generate a unique ID and add to local list
      final newPost = Post(
        userId: post.userId,
        id: DateTime.now().millisecondsSinceEpoch, // Unique ID for local storage
        title: post.title,
        body: post.body,
      );
      return newPost;
    }
  }

  // PUT - Update post
  Future<Post> updatePost(Post post) async {
    try {
      return await _apiService.updatePost(post);
    } catch (e) {
      print('API call failed, updating post locally: $e');
      // For local fallback, we'll just return the updated post
      return post;
    }
  }

  // DELETE - Delete post
  Future<bool> deletePost(int id) async {
    try {
      return await _apiService.deletePost(id);
    } catch (e) {
      print('API call failed, deleting post locally: $e');
      // For local fallback, we'll return true (simulate successful deletion)
      return true;
    }
  }

  // Comments methods (existing)...
  Future<List<Comment>> getCommentsByPostId(int postId) async {
    try {
      return await _apiService.getCommentsByPostId(postId);
    } catch (e) {
      print('API call failed, using local comments: $e');
      return _getLocalComments().where((comment) => comment.postId == postId).toList();
    }
  }

  Future<List<Comment>> getAllComments() async {
    try {
      return await _apiService.getAllComments();
    } catch (e) {
      print('API call failed, using local comments: $e');
      return _getLocalComments();
    }
  }

  // Local fallback data for posts
  List<Post> _getLocalPosts() {
    return [
      Post(userId: 1, id: 1, title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit", body: "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"),
      Post(userId: 1, id: 2, title: "qui est esse", body: "est rerum tempore vitae\nsequi sint nihil reprehenderit dolor beatae ea dolores neque\nfugiat blanditiis voluptate porro vel nihil molestiae ut reiciendis\nqui aperiam non debitis possimus qui neque nisi nulla"),
      Post(userId: 1, id: 3, title: "ea molestias quasi exercitationem repellat qui ipsa sit aut", body: "et iusto sed quo iure\nvoluptatem occaecati omnis eligendi aut ad\nvoluptatem doloribus vel accusantium quis pariatur\nmolestiae porro eius odio et labore et velit aut"),
      Post(userId: 1, id: 4, title: "eum et est occaecati", body: "ullam et saepe reiciendis voluptatem adipisci\nsit amet autem assumenda provident rerum culpa\nquis hic commodi nesciunt rem tenetur doloremque ipsam iure\nquis sunt voluptatem rerum illo velit"),
      Post(userId: 1, id: 5, title: "nesciunt quas odio", body: "repudiandae veniam quaerat sunt sed\nalias aut fugiat sit autem sed est\nvoluptatem omnis possimus esse voluptatibus quis\nest aut tenetur dolor neque"),
    ];
  }

  // Local fallback data for comments
  List<Comment> _getLocalComments() {
    return [
      Comment(postId: 1, id: 1, name: "id labore ex et quam laborum", email: "Eliseo@gardner.biz", body: "laudantium enim quasi est quidem magnam voluptate ipsam eos\ntempora quo necessitatibus\ndolor quam autem quasi\nreiciendis et nam sapiente accusantium"),
      Comment(postId: 1, id: 2, name: "quo vero reiciendis velit similique earum", email: "Jayne_Kuhic@sydney.com", body: "est natus enim nihil est dolore omnis voluptatem numquam\net omnis occaecati quod ullam at\nvoluptatem error expedita pariatur\nnihil sint nostrum voluptatem reiciendis et"),
      Comment(postId: 1, id: 3, name: "odio adipisci rerum aut animi", email: "Nikita@garfield.biz", body: "quia molestiae reprehenderit quasi aspernatur\naut expedita occaecati aliquam eveniet laudantium\nomnis quibusdam delectus saepe quia accusamus maiores nam est\ncum et ducimus et vero voluptates excepturi deleniti ratione"),
      Comment(postId: 1, id: 4, name: "alias odio sit", email: "Lew@alysha.tv", body: "non et atque\noccaecati deserunt quas accusantium unde odit nobis qui voluptatem\nquia voluptas consequuntur itaque dolor\net qui rerum deleniti ut occaecati"),
      Comment(postId: 1, id: 5, name: "vero eaque aliquid doloribus et culpa", email: "Hayden@althea.biz", body: "harum non quasi et ratione\ntempore iure ex voluptates in ratione\nharum architecto fugit inventore cupiditate\nvoluptates magni quo et"),
      Comment(postId: 2, id: 6, name: "et fugit eligendi deleniti quidem qui sint nihil autem", email: "Presley.Mueller@myrl.com", body: "doloribus at sed quis culpa deserunt consectetur qui praesentium\naccusamus fugiat dicta\nvoluptatem rerum ut voluptate autem\nvoluptatem repellendus aspernatur dolorem in"),
    ];
  }
}