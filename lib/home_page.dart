import 'package:flutter/material.dart';
import 'posts_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email; // Ensure this is passed correctly
  final int userId;

  const HomePage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.userId,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentIndex == 0 ? "Posts" : "Profile"),
      ),
      body: IndexedStack(
        index: currentIndex,
        children: [
          // Pass values to PostsPage
          PostsPage(
            firstName: widget.firstName,
            lastName: widget.lastName,
            userId: widget.userId,
          ),
          // Pass all values to ProfilePage
          ProfilePage(
            firstName: widget.firstName,
            lastName: widget.lastName,
            email: widget.email, // Pass email properly
            userId: widget.userId,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add),
            label: 'Posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
