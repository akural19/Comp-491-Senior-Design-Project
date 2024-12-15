import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';
import 'onboarding_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  // Google Sign-In
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      // Check if onboarding has been shown before
      final prefs = await SharedPreferences.getInstance();
      final showOnboarding = prefs.getBool('showOnboarding') ?? true;

      if (showOnboarding) {
        // Navigate to OnboardingScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => OnboardingScreen()),
        );
      } else {
        // Navigate to HomePage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
      /*
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
       */
    } catch (e) {
      _showError("Google Sign-In failed. Please try again.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/sign_speak_nobg.png', // Add Google logo in assets
                      height: 400,
                      width: 400,
                    ),
                    //const SizedBox(height: 40),
                    // Google Sign-In Button
                    GestureDetector(
                      onTap: _signInWithGoogle,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/google_logo1.png', // Add Google logo in assets
                              height: 24,
                              width: 24,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Sign in with Google",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
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
