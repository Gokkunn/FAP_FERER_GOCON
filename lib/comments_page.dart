import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentsPage extends StatelessWidget {
  final String postId;
  final String firstName;
  final String lastName;
  final int userId;

  const CommentsPage({
    super.key,
    required this.postId,
    required this.firstName,
    required this.lastName,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comments on $firstName $lastName's Post"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tbl_comments')
            .where('post_id', isEqualTo: postId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error loading comments: ${snapshot.error}"),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No comments yet."));
          }

          final comments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              final content = comment['content'] ?? 'No content';

              return ListTile(
                title: Text("$firstName $lastName"),
                subtitle: Text(content),
              );
            },
          );
        },
      ),
    );
  }
}
