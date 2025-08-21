import 'package:api/provider/post_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import 'post_detail_screen.dart';
import 'post_form_screen.dart'; // Add this import

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

  void _navigateToAddPost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PostFormScreen(),
      ),
    );
  }

  void _navigateToEditPost(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostFormScreen(post: post),
      ),
    );
  }

  Future<void> _confirmDeletePost(Post post) async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "${post.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await postProvider.deletePost(post.id);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
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
          // Add New Post Button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddPost,
            tooltip: 'Add New Post',
          ),
          // Refresh Button
          Consumer<PostProvider>(
            builder: (context, postProvider, child) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: postProvider.isLoading ? null : () => postProvider.refreshPosts(),
                tooltip: 'Refresh Posts',
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
              return _buildPostCard(post, postProvider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPostCard(Post post, PostProvider postProvider) {
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit Button
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _navigateToEditPost(post),
              tooltip: 'Edit Post',
            ),
            // Delete Button
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => _confirmDeletePost(post),
              tooltip: 'Delete Post',
            ),
          ],
        ),
        onTap: () => _navigateToPostDetail(post),
      ),
    );
  }
}