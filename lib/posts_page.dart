import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_item.dart';

class PostsPage extends StatefulWidget {
  final int currentUserId;

  const PostsPage({super.key, required this.currentUserId});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tbl_posts').snapshots(),
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
            return PostItem(
              postId: post['post_id'],
              userId: post['user_id'],
              content: post['content'],
              imageUrl: post['image_url'],
              timestamp: post['timestamp'],
              likesCount: post['likes_count'],
              commentsCount: post['comments_count'],
              currentUserId: widget.currentUserId,
            );
          },
        );
      },
    );
  }
}
