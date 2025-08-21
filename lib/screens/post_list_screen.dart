// import 'package:flutter/material.dart';
// import '../models/post.dart';
// import '../repositories/post_repository.dart';
// import 'post_detail_screen.dart';

// class PostListScreen extends StatefulWidget {
//   const PostListScreen({super.key});

//   @override
//   State<PostListScreen> createState() => _PostListScreenState();
// }

// class _PostListScreenState extends State<PostListScreen> {
//   final PostRepository _postRepository = PostRepository();
//   List<Post> _posts = [];
//   bool _isLoading = true;
//   String _errorMessage = '';
//   bool _usingLocalData = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadPosts();
//   }

//   Future<void> _loadPosts() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//       _usingLocalData = false;
//     });

//     try {
//       final posts = await _postRepository.getAllPosts();
//       setState(() {
//         _posts = posts;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to load posts: $e';
//         _isLoading = false;
//         _usingLocalData = true;
//       });
//     }
//   }

//   void _navigateToPostDetail(Post post) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => PostDetailScreen(post: post),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Posts'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadPosts,
//           ),
//         ],
//       ),
//       body: _buildBody(),
//     );
//   }

//   Widget _buildBody() {
//     if (_isLoading) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text('Loading posts...'),
//           ],
//         ),
//       );
//     }

//     if (_errorMessage.isNotEmpty && _posts.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error_outline, size: 64, color: Colors.red),
//             const SizedBox(height: 16),
//             Text(
//               _errorMessage,
//               style: const TextStyle(color: Colors.red, fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _loadPosts,
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     return Column(
//       children: [
//         if (_usingLocalData)
//           Container(
//             padding: const EdgeInsets.all(8),
//             color: Colors.orange[100],
//             child: Row(
//               children: [
//                 const Icon(Icons.warning, color: Colors.orange),
//                 const SizedBox(width: 8),
//                 const Expanded(
//                   child: Text(
//                     'Using local data (API unavailable)',
//                     style: TextStyle(color: Colors.orange),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close, size: 20),
//                   onPressed: () {
//                     setState(() {
//                       _usingLocalData = false;
//                     });
//                   },
//                 ),
//               ],
//             ),
//           ),
//         Expanded(
//           child: ListView.builder(
//             itemCount: _posts.length,
//             itemBuilder: (context, index) {
//               final post = _posts[index];
//               return Card(
//                 margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                 child: ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor: Colors.blue,
//                     child: Text(
//                       post.id.toString(),
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   ),
//                   title: Text(
//                     post.title,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   subtitle: Text(
//                     post.body.replaceAll('\n', ' '),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   onTap: () => _navigateToPostDetail(post),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }



import 'package:api/models/post.dart';
import 'package:api/provider/post_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'post_detail_screen.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  @override
  void initState() {
    super.initState();
    // Load posts when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      postProvider.loadPosts();
    });
  }

  void _navigateToPostDetail(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(post: post),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Consumer<PostProvider>(
            builder: (context, postProvider, child) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: postProvider.isLoading ? null : () => postProvider.refreshPosts(),
              );
            },
          ),
        ],
      ),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          return _buildBody(postProvider);
        },
      ),
    );
  }

  Widget _buildBody(PostProvider postProvider) {
    if (postProvider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading posts...'),
          ],
        ),
      );
    }

    if (postProvider.errorMessage.isNotEmpty && postProvider.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              postProvider.errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => postProvider.loadPosts(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (postProvider.usingLocalData)
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.orange[100],
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Using local data (API unavailable)',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => postProvider.clearError(),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: postProvider.posts.length,
            itemBuilder: (context, index) {
              final post = postProvider.posts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      post.id.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    post.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    post.body.replaceAll('\n', ' '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _navigateToPostDetail(post),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}