import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentsPage extends StatelessWidget {
  final String postId;
  final String firstName;
  final String lastName;
  final int currentUserId;

  const CommentsPage({
    super.key,
    required this.postId,
    required this.firstName,
    required this.lastName,
    required this.currentUserId,
  });

  Future<Map<String, String>> _fetchUserName(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('tbl_users')
          .where('user_id', isEqualTo: int.parse(userId)) // Ensure parsing
          .get();

      if (userDoc.docs.isNotEmpty) {
        final userData = userDoc.docs.first.data();
        return {
          "firstName": userData['firstName'] ?? "Unknown",
          "lastName": userData['lastName'] ?? "User",
        };
      }
    } catch (e) {
      // Handle error
    }
    return {"firstName": "Unknown", "lastName": "User"};
  }

  Future<void> _postComment(BuildContext context, String content) async {
    if (content.trim().isEmpty) return;

    try {
      final commentId = FirebaseFirestore.instance.collection('tbl_comments').doc().id;

      await FirebaseFirestore.instance.collection('tbl_comments').doc(commentId).set({
        'comment_id': commentId,
        'post_id': postId,
        'user_id': currentUserId.toString(),
        'content': content.trim(),
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment posted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting comment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController commentController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments"),
      ),
      body: Column(
        children: [
          // Add comment field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: 'Add a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _postComment(context, commentController.text);
                    commentController.clear();
                  },
                ),
              ),
            ),
          ),
          // Display comments
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tbl_comments')
                  .where('post_id', isEqualTo: postId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No comments yet."));
                }

                final comments = snapshot.data!.docs
                  ..sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

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
                            subtitle: Text(content),
                          );
                        }

                        final userName = userSnapshot.data!;
                        return ListTile(
                          title: Text("${userName['firstName']} ${userName['lastName']}"),
                          subtitle: Text(content),
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
