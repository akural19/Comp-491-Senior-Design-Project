import 'package:flutter/material.dart';

class TranscriptionInProgressScreen extends StatelessWidget {
  const TranscriptionInProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animation or Progress Indicator
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 5.0,
            ),
            const SizedBox(height: 20),
            // Text Message
            const Text(
              "Transcription in progress...\nPlease wait",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
