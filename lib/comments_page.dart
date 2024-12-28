import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentsPage extends StatefulWidget {
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
        'user_id': widget.currentUserId.toString(),
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

                    return ListTile(
                      title: Text("${widget.firstName} ${widget.lastName}"),
                      subtitle: Text(content),
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
