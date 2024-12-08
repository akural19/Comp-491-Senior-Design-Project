import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'real_time_transcription_page.dart';
import 'recording_page.dart'; // Import the recording page
import 'sign_in_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sign-Speak Communication Assistant',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const SignInScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Speech to Text Converter
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecordingPage(),
                  ),
                );

                // Show feedback from RecordingPage
                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.toString()),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
              child: FeatureCard(
                icon: Icons.keyboard_voice_outlined,
                title: 'Speech to Text Converter',
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 16),

            // Sign to Text Converter
            GestureDetector(
              onTap: () {
                // Navigate to Sign to Text Converter page (to be implemented)
              },
              child: FeatureCard(
                icon: Icons.account_tree_outlined,
                title: 'Sign to Text Converter',
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RealTimeTranscriptionPage(),
                  ),
                );
              },
              child: FeatureCard(
                icon: Icons.record_voice_over_outlined,
                title: 'Real-Time Transcription',
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 50,
            color: Colors.white,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Ensure text color matches the design
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
