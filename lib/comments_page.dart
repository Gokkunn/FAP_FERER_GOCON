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
      backgroundColor: const Color.fromRGBO(1, 10, 27, 1), // Dark background
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(20, 30, 50, 1), // Darker AppBar
        title: const Text(
          "Comments",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold), // White text for contrast
        ),
        iconTheme: const IconThemeData(color: Colors.white), // White back arrow
        elevation: 0,
      ),
      body: Column(
        children: [
          // Add comment field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: commentController,
              style: const TextStyle(color: Colors.white), // Input text color
              decoration: InputDecoration(
                labelText: 'Add a comment...',
                labelStyle: const TextStyle(color: Colors.grey), // Label color
                filled: true,
                fillColor: const Color.fromRGBO(20, 30, 50, 1), // Dark input field
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent), // Highlighted arrow
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
                  return const Center(
                    child: Text(
                      "No comments yet.",
                      style: TextStyle(color: Colors.grey), // Grey text for empty state
                    ),
                  );
                }

                final comments = snapshot.data!.docs
                  ..sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

                return ListView.separated(
                  itemCount: comments.length,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey.withOpacity(0.3), // Subtle divider color
                    thickness: 0.5,
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final content = comment['content'] ?? 'No content';
                    final commentUserId = comment['user_id'];

                    return FutureBuilder<Map<String, String>>(
                      future: _fetchUserName(commentUserId),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState == ConnectionState.waiting) {
                          return const ListTile(
                            title: Text("Loading...", style: TextStyle(color: Colors.grey)),
                            subtitle:
                                Text("Fetching user data", style: TextStyle(color: Colors.grey)),
                          );
                        }

                        if (userSnapshot.hasError || userSnapshot.data == null) {
                          return ListTile(
                            title: const Text("Unknown User", style: TextStyle(color: Colors.grey)),
                            subtitle: Text(content, style: const TextStyle(color: Colors.white)),
                          );
                        }

                        final userName = userSnapshot.data!;
                        return ListTile(
                          title: Text(
                            "${userName['firstName']} ${userName['lastName']}",
                            style: const TextStyle(color: Colors.white), // White text
                          ),
                          subtitle: Text(
                            content,
                            style: const TextStyle(color: Colors.grey), // Grey text for content
                          ),
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
