import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_item.dart';

class PostsPage extends StatefulWidget {
  final int currentUserId;
  final String loggedInFirstName;
  final String loggedInLastName;

  const PostsPage({
    super.key,
    required this.currentUserId,
    required this.loggedInFirstName,
    required this.loggedInLastName,
  });

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final TextEditingController postController = TextEditingController();

  Future<void> _createPost() async {
    if (postController.text.trim().isEmpty) return;

    try {
      final postId = FirebaseFirestore.instance.collection('tbl_posts').doc().id;
      await FirebaseFirestore.instance.collection('tbl_posts').doc(postId).set({
        'post_id': postId,
        'user_id': widget.currentUserId,
        'content': postController.text.trim(),
        'image_url': '',
        'timestamp': Timestamp.now(),
        'likes_count': 0,
        'liked_by': [],
      });

      postController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating post: $e')),
      );
    }
  }

  Future<Map<String, String>> _fetchUserName(int userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('tbl_users')
          .where('user_id', isEqualTo: userId)
          .get();

      if (userDoc.docs.isNotEmpty) {
        final data = userDoc.docs.first.data();
        return {
          "firstName": data['firstName'] ?? "Unknown",
          "lastName": data['lastName'] ?? "User",
        };
      }
    } catch (e) {
      // Handle error
    }
    return {"firstName": "Unknown", "lastName": "User"};
  }

  Future<void> _toggleLike(String postId, List<dynamic> likedBy) async {
    try {
      final isLiked = likedBy.contains(widget.currentUserId);
      final postRef = FirebaseFirestore.instance.collection('tbl_posts').doc(postId);

      if (isLiked) {
        await postRef.update({
          'likes_count': FieldValue.increment(-1),
          'liked_by': FieldValue.arrayRemove([widget.currentUserId]),
        });
      } else {
        await postRef.update({
          'likes_count': FieldValue.increment(1),
          'liked_by': FieldValue.arrayUnion([widget.currentUserId]),
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling like: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(1, 10, 27, 1), // Dark background
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: postController,
              style: const TextStyle(color: Colors.white), // Text color in dark mode
              decoration: InputDecoration(
                labelText: 'What\'s on your mind?',
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color.fromRGBO(20, 30, 50, 1), // Input field background
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _createPost,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tbl_posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No posts available.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final posts = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final likedBy =
                        (post.data() as Map<String, dynamic>)['liked_by'] ?? <dynamic>[];

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('tbl_comments')
                          .where('post_id', isEqualTo: post['post_id'])
                          .snapshots(),
                      builder: (context, commentSnapshot) {
                        final commentsCount = commentSnapshot.data?.docs.length ?? 0;

                        return FutureBuilder<Map<String, String>>(
                          future: _fetchUserName(post['user_id']),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final userName =
                                userSnapshot.data ?? {"firstName": "Unknown", "lastName": "User"};

                            return PostItem(
                              postId: post['post_id'],
                              userId: post['user_id'],
                              content: post['content'],
                              imageUrl: post['image_url'],
                              timestamp: post['timestamp'],
                              likesCount: post['likes_count'],
                              commentsCount: commentsCount,
                              currentUserId: widget.currentUserId,
                              firstName: userName['firstName']!,
                              lastName: userName['lastName']!,
                              isLiked: likedBy.contains(widget.currentUserId),
                              onLikePressed: () => _toggleLike(post['post_id'], likedBy),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
