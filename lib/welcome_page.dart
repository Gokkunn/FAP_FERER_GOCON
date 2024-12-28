import 'package:flutter/material.dart';
import 'package:fap_ferrer_gocon/signup_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(1, 10, 27, 1),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(
                image: AssetImage('images/welcome.jpg'),
                height: 300,
                width: 300,
              ),
              const Text(
                'Welcome to',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              const Text(
                'AstroLink',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              // const SizedBox(height: 10),
              const Text(
                '"Guiding Connections, Lighting Careers"',
                style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontSize: 15),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(90, 50), // change the size of the box
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ));
  }
}
