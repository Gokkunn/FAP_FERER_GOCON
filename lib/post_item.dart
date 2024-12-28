import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'comments_page.dart';

class PostItem extends StatefulWidget {
  final String postId;
  final int userId;
  final String content;
  final String imageUrl;
  final Timestamp timestamp;
  final int likesCount;
  final int commentsCount;
  final int currentUserId;

  const PostItem({
    super.key,
    required this.postId,
    required this.userId,
    required this.content,
    required this.imageUrl,
    required this.timestamp,
    required this.likesCount,
    required this.commentsCount,
    required this.currentUserId,
  });

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  String userName = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('tbl_users')
          .where('user_id', isEqualTo: widget.userId)
          .get();

      if (userDoc.docs.isNotEmpty) {
        final userData = userDoc.docs.first.data();
        setState(() {
          userName = "${userData['firstName']} ${userData['lastName']}";
        });
      } else {
        setState(() {
          userName = "Unknown User";
        });
      }
    } catch (e) {
      setState(() {
        userName = "Error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final postDate = widget.timestamp.toDate();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(userName), // Display the fetched user's name
            subtitle: Text(
              '${postDate.day}/${postDate.month}/${postDate.year} ${postDate.hour}:${postDate.minute}',
            ),
          ),
          if (widget.imageUrl.isNotEmpty) Image.network(widget.imageUrl, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.content),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  // Implement like functionality here
                },
                icon: const Icon(Icons.thumb_up),
                label: Text(widget.likesCount.toString()),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommentsPage(postId: widget.postId),
                    ),
                  );
                },
                child: Text("Comments (${widget.commentsCount})"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
