import 'package:flutter/material.dart';
import 'posts_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
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
      backgroundColor: const Color.fromRGBO(1, 10, 27, 1), // Dark background
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(20, 30, 50, 1), // Darker AppBar color
        title: Text(
          currentIndex == 0 ? "Posts" : "Profile",
          style: const TextStyle(
            color: Colors.white, // White text for contrast
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0, // Flat app bar for a modern look
      ),
      body: IndexedStack(
        index: currentIndex,
        children: [
          PostsPage(
            currentUserId: widget.userId,
            loggedInFirstName: widget.firstName, // Pass logged-in user's first name
            loggedInLastName: widget.lastName, // Pass logged-in user's last name
          ),
          ProfilePage(
            firstName: widget.firstName,
            lastName: widget.lastName,
            email: widget.email,
            userId: widget.userId,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(20, 30, 50, 1), // Darker background
        currentIndex: currentIndex,
        selectedItemColor: Colors.blueAccent, // Highlight for selected item
        unselectedItemColor: Colors.grey, // Subtle color for unselected items
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
