import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_item.dart';

class PostsPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final int userId;

  const PostsPage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.userId,
  });

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final TextEditingController postController = TextEditingController();

  Future<void> _createPost() async {
    if (postController.text.trim().isEmpty) return;

    final postId = FirebaseFirestore.instance.collection('tbl_posts').doc().id;
    await FirebaseFirestore.instance.collection('tbl_posts').doc(postId).set({
      'post_id': postId,
      'user_id': widget.userId,
      'content': postController.text,
      'image_url': '',
      'timestamp': Timestamp.now(),
      'likes_count': 0,
      'comments_count': 0,
    });

    postController.clear();
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
              labelText: 'Create a new post',
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
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No posts available."));
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final post = snapshot.data!.docs[index];
                  return PostItem(
                    postId: post['post_id'],
                    userId: post['user_id'],
                    content: post['content'],
                    imageUrl: post['image_url'],
                    timestamp: post['timestamp'],
                    likesCount: post['likes_count'],
                    commentsCount: post['comments_count'],
                    currentUserId: widget.userId,
                    firstName: widget.firstName,
                    lastName: widget.lastName,
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
