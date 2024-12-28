import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentsPage extends StatefulWidget {
  final String postId;

  const CommentsPage({super.key, required this.postId});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController commentController = TextEditingController();

  Future<void> _postComment() async {
    if (commentController.text.trim().isEmpty) return;

    try {
      final commentId = FirebaseFirestore.instance.collection('tbl_comments').doc().id;
      await FirebaseFirestore.instance.collection('tbl_comments').doc(commentId).set({
        'comment_id': commentId,
        'post_id': widget.postId,
        'user_id': "current_user_id", // Replace with the actual current user ID
        'content': commentController.text.trim(),
        'timestamp': Timestamp.now(),
      });

      commentController.clear();
    } catch (e) {
      debugPrint("Error posting comment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to post comment: $e")),
      );
    }
  }

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
      debugPrint("Error fetching user name: $e");
    }
    return {"firstName": "Unknown", "lastName": "User"};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments"),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tbl_comments')
                  .where('post_id', isEqualTo: widget.postId)
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: "Write a comment...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _postComment,
                  child: const Text("Post"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
