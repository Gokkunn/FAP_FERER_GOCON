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
  final String firstName;
  final String lastName;
  final bool isLiked; // Indicates if the current user has liked the post
  final VoidCallback onLikePressed; // Function to toggle like state

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
    required this.firstName,
    required this.lastName,
    required this.isLiked,
    required this.onLikePressed,
  });

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  @override
  Widget build(BuildContext context) {
    final postDate = widget.timestamp.toDate();

    return Card(
      color: const Color.fromRGBO(20, 30, 50, 1), // Dark card background
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      elevation: 4, // Slight elevation for depth
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              '${widget.firstName} ${widget.lastName}',
              style: const TextStyle(
                color: Colors.white, // White text for dark mode
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${postDate.day}/${postDate.month}/${postDate.year} ${postDate.hour}:${postDate.minute}',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          if (widget.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.content,
              style: const TextStyle(
                color: Colors.white, // White text for readability
                fontSize: 16,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: widget.onLikePressed, // Toggles the like state
                icon: Icon(
                  widget.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                  color: widget.isLiked ? Colors.blueAccent : Colors.grey,
                ),
                label: Text(
                  widget.likesCount.toString(),
                  style: const TextStyle(color: Colors.white), // White text for likes count
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommentsPage(
                        postId: widget.postId,
                        currentUserId: widget.currentUserId,
                        firstName: widget.firstName,
                        lastName: widget.lastName,
                      ),
                    ),
                  );
                },
                child: Text(
                  "Comments (${widget.commentsCount})",
                  style: const TextStyle(color: Colors.white), // White text for comments count
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
