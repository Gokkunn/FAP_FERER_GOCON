import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int currentIndex = 0;
  final TextEditingController bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBio();
  }

  Future<void> _fetchBio() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('tbl_users')
          .where('user_id', isEqualTo: widget.userId)
          .get();

      if (userDoc.docs.isNotEmpty) {
        setState(() {
          bioController.text =
              userDoc.docs.first.data().containsKey('bio') ? userDoc.docs.first['bio'] : '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching bio: $e")),
      );
    }
  }

  Future<void> _updateBio() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('tbl_users')
          .where('user_id', isEqualTo: widget.userId)
          .get();

      if (userDoc.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('tbl_users')
            .doc(userDoc.docs.first.id)
            .update({'bio': bioController.text});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bio updated successfully!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating bio: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: IndexedStack(
        index: currentIndex,
        children: [
          const Center(child: Text('Home Page')), // Home page
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.firstName} ${widget.lastName}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: bioController,
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _updateBio,
                    child: const Text("Update Bio"),
                  ),
                ],
              ),
            ),
          ), // Profile page
          const Center(child: Text('Menu Page')), // Menu page
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
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}
