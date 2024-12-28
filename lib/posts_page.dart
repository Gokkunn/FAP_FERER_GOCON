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
        'image_url': '', // Placeholder for future image support
        'timestamp': Timestamp.now(),
        'likes_count': 0,
        'comments_count': 0,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: postController,
            decoration: InputDecoration(
              labelText: 'What\'s on your mind?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _createPost,
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('tbl_posts')
                .orderBy('timestamp', descending: true) // Display newest posts first
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No posts available."));
              }

              final posts = snapshot.data!.docs;

              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
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
                        commentsCount: post['comments_count'],
                        currentUserId: widget.currentUserId,
                        firstName: userName['firstName']!,
                        lastName: userName['lastName']!,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
