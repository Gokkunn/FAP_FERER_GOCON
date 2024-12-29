import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup_page.dart';

class ProfilePage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final int userId;

  const ProfilePage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.userId,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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

  void _logout() {
    // Clear session or perform any logout operations here
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignUpPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(1, 10, 27, 1), // Dark background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${widget.firstName} ${widget.lastName}",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Text color for contrast
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "User ID: ${widget.userId}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              Divider(
                color: Colors.grey.withOpacity(0.5),
                thickness: 0.5,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: bioController,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color.fromRGBO(20, 30, 50, 1), // Darker input field background
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white), // Input text color
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _updateBio,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(30, 60, 90, 1), // Button background color
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Update Bio",
                    style: TextStyle(
                      color: Colors.white, // Button text color
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Logout button color
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.white, // Button text color
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
