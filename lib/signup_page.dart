import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fap_ferrer_gocon/home_page.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignInSignUpPage(),
    );
  }
}

class SignInSignUpPage extends StatefulWidget {
  const SignInSignUpPage({super.key});

  @override
  SignInSignUpPageState createState() => SignInSignUpPageState();
}

class SignInSignUpPageState extends State<SignInSignUpPage> with SingleTickerProviderStateMixin {
  late TabController tabController;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // SignUp
  final GlobalKey<FormState> signUpKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController signUpEmailController = TextEditingController();
  final TextEditingController signUpPasswordController = TextEditingController();
  bool isSignUpPasswordVisible = false;

  // SignIn
  final GlobalKey<FormState> signInKey = GlobalKey<FormState>();
  final TextEditingController signInEmailController = TextEditingController();
  final TextEditingController signInPasswordController = TextEditingController();
  bool isSignInPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TabBar(
                  controller: tabController,
                  indicatorColor: const Color.fromRGBO(83, 100, 147, 1),
                  labelColor: const Color.fromRGBO(83, 100, 147, 1),
                  unselectedLabelColor: Colors.white,
                  tabs: const [
                    Tab(text: "LOGIN"),
                    Tab(text: "SIGN UP"),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      buildLoginForm(),
                      buildSignUpForm(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSignUpForm() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Form(
            key: signUpKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: firstNameController,
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          labelStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(83, 100, 147, 1),
                            ),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your first name";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: lastNameController,
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          labelStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(83, 100, 147, 1),
                            ),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) => value!.isEmpty ? 'Please enter last name' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: signUpEmailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color.fromRGBO(83, 100, 147, 1),
                      ),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) => value!.isEmpty ? 'Please enter email' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: signUpPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color.fromRGBO(83, 100, 147, 1),
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isSignUpPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          isSignUpPasswordVisible = !isSignUpPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !isSignUpPasswordVisible,
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a password";
                    } else if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(83, 100, 147, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    onPressed: () async {
                      if (signUpKey.currentState!.validate()) {
                        await storeFireData();
                      }
                    },
                    child: const Text("SIGN UP", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLoginForm() {
    return Form(
      key: signInKey,
      child: Column(
        children: [
          const SizedBox(height: 30),
          TextFormField(
            controller: signInEmailController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: const TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color.fromRGBO(83, 100, 147, 1),
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your email";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: signInPasswordController,
            style: const TextStyle(color: Colors.white),
            obscureText: !isSignInPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: const TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color.fromRGBO(83, 100, 147, 1),
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isSignInPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    isSignInPasswordVisible = !isSignInPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter a password";
              } else if (value.length < 6) {
                return "Password must be at least 6 characters";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(83, 100, 147, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            onPressed: () async {
              if (signInKey.currentState!.validate()) {
                final userData = await validateLoginCredentials(
                  email: signInEmailController.text,
                  password: signInPasswordController.text,
                );

                if (userData != null) {
                  navigateToHome(
                    firstName: userData['firstName'],
                    lastName: userData['lastName'],
                    email: signInEmailController.text,
                    userId: userData['user_id'],
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Wrong email or password!")),
                  );
                }
              }
            },
            child: const Text("LOG IN", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> validateLoginCredentials({
    required String email,
    required String password,
  }) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('tbl_users')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }
      return null;
    } catch (e) {
      log("Error validating credentials: $e", name: "LoginValidation");
      return null;
    }
  }

  void navigateToHome({
    required String firstName,
    required String lastName,
    required String email,
    required int userId,
  }) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(
          firstName: firstName,
          lastName: lastName,
          email: email,
          userId: userId,
        ),
      ),
    );
  }

  Future<void> storeFireData() async {
    try {
      final usersCollection = FirebaseFirestore.instance.collection('tbl_users');

      final querySnapshot =
          await usersCollection.orderBy('user_id', descending: true).limit(1).get();
      int nextUserId = 1;
      if (querySnapshot.docs.isNotEmpty) {
        nextUserId = querySnapshot.docs.first['user_id'] + 1;
      }

      await usersCollection.add({
        'user_id': nextUserId,
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'email': signUpEmailController.text,
        'password': signUpPasswordController.text,
      });

      firstNameController.clear();
      lastNameController.clear();
      signUpEmailController.clear();
      signUpPasswordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sign Up Successful! Fields cleared.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error storing user data: $e")),
      );
    }
  }
}
