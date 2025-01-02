/*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'real_time_transcription_page.dart';
import 'recording_page.dart'; // Import the recording page
import 'sign_in_screen.dart';
import 'video_recording_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Communication Assistant',
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
                title: 'Advanced Transcription',
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 16),

            // Sign to Text Converter
            GestureDetector(
              onTap: () {
                // Navigate to Sign to Text Converter page (to be implemented)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const VideoRecordingPage()),
                );
              },
              child: FeatureCard(
                icon: Icons.account_tree_outlined,
                title: 'Sign to Speech Converter',
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
*/

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'real_time_transcription_page.dart';
import 'recording_page.dart';
import 'sign_in_screen.dart';
import 'video_recording_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Communication Assistant',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        //backgroundColor: Colors.blue.shade700,
        backgroundColor: const Color(0xFF12182A),
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const SignInScreen()),
              );
            },
          ),
        ],
      ),
      //backgroundColor: Colors.grey.shade800,
      backgroundColor: const Color(0xFF12182A),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FeatureCard(
                icon: Icons.text_snippet_outlined,
                title: 'Advanced Transcription',
                description: 'Convert speech to text effortlessly.',
                color: const Color(0xFF3C83F7),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecordingPage(),
                    ),
                  );

                  if (result != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result.toString()),
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              FeatureCard(
                icon: Icons.translate_outlined,
                title: 'Sign to Speech Converter',
                description: 'Translate sign language to speech.',
                color: const Color(0xFF3C83F7),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VideoRecordingPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              FeatureCard(
                icon: Icons.mic_outlined,
                title: 'Real-Time Transcription',
                description: 'Live transcription of conversations.',
                color: const Color(0xFF3C83F7),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RealTimeTranscriptionPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: color,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
