import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';
import 'sign_in_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() async {
    // Simulate a delay for splash experience
    await Future.delayed(const Duration(seconds: 2));

    // Check if a user is logged in
    if (FirebaseAuth.instance.currentUser != null) {
      // Navigate to HomePage if authenticated
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      // Navigate to SignInScreen if not authenticated
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12182A),
      body: Center(
        child: Image.asset(
          'assets/sign_speak_nobg.png', // Change this to 'assets/sign_speak_nobg.png' if preferred
          width: 400, // Adjust the size as needed
          height: 400, // Adjust the size as needed
        ),
      ),
    );
  }
}
