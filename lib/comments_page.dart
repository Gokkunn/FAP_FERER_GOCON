import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentsPage extends StatelessWidget {
  final String postId;

  const CommentsPage({super.key, required this.postId});

  Future<Map<String, String>> _fetchUserName(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('tbl_users')
          .where('user_id', isEqualTo: int.tryParse(userId))
          .get();

      if (userDoc.docs.isNotEmpty) {
        final userData = userDoc.docs.first.data();
        return {
          "firstName": userData['firstName'] ?? "Unknown",
          "lastName": userData['lastName'] ?? "User"
        };
      }
    } catch (e) {
      // Handle error
    }
    return {"firstName": "Unknown", "lastName": "User"};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments"),
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
              final commentUserId = comment['user_id'];

              return FutureBuilder<Map<String, String>>(
                future: _fetchUserName(commentUserId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text("Loading..."),
                      subtitle: Text("Fetching user data"),
                    );
                  }

                  if (userSnapshot.hasError || userSnapshot.data == null) {
                    return ListTile(
                      title: const Text("Unknown User"),
                      subtitle: Text(content), // Removed `const` here
                    );
                  }

                  final userName = userSnapshot.data!;
                  return ListTile(
                    title: Text("${userName['firstName']} ${userName['lastName']}"),
                    subtitle: Text(content), // Removed `const` here
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
