import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class SignLanguageRecognitionResultPage extends StatefulWidget {
  final String videoPath;
  final String result;

  const SignLanguageRecognitionResultPage({
    Key? key,
    required this.videoPath,
    required this.result,
  }) : super(key: key);

  @override
  _SignLanguageRecognitionResultPageState createState() =>
      _SignLanguageRecognitionResultPageState();
}

class _SignLanguageRecognitionResultPageState
    extends State<SignLanguageRecognitionResultPage> {
  late AudioPlayer _audioPlayer;
  bool _isLoadingAudio = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _generateFileName(String text) {
    // Clean the text and create a unique filename
    final cleanText = text
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();

    // Add timestamp for uniqueness
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Include first 30 characters of text and timestamp
    return "tts_${cleanText.substring(0, min(30, cleanText.length))}_$timestamp.mp3";
  }

// Also modify the cache check to be more strict
  Future<String?> _getExistingAudioPath(String fileName) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/$fileName");

      // Always return null to force new file generation
      return null;

      /* Remove or comment out the cache check
    if (await file.exists() && await file.length() > 0) {
      return file.path;
    }
    return null;
    */
    } catch (e) {
      print("Cache check error: $e");
      return null;
    }
  }

  Future<void> _generateAndPlayAudio(String text) async {
    setState(() {
      _isLoadingAudio = true;
    });

    try {
      // Clean and prepare the text
      if (text.contains(':')) {
        text = text.split(':').last.trim();
      }

      // Remove any "The depicted text is" prefix if present
      text = text.replaceAll("The depicted text is", "").trim();

      // Generate filename based on text content
      final fileName = _generateFileName(text);

      // Check cache first
      final existingPath = await _getExistingAudioPath(fileName);
      if (existingPath != null) {
        print("Using cached audio file for: $text");
        await _audioPlayer.play(DeviceFileSource(existingPath));
        return;
      }

      print("Generating audio for text: '$text'");

      String? apiKey = dotenv.env['CHATGPT_API_KEY'];

      if (apiKey == null) {
        print("API key not found!");
        return;
      }
      final apiUrl = "https://api.openai.com/v1/audio/speech";

      // Prepare the request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "tts-1",
          "voice": "nova",
          "input": "The depicted text is $text",
          "response_format": "mp3",
          "speed": 1.0,
        }),
      );

      print("TTS API Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Save the audio file
        final dir = await getTemporaryDirectory();
        final filePath = "${dir.path}/$fileName";
        final audioFile = File(filePath);

        await audioFile.writeAsBytes(response.bodyBytes);
        print("Audio file saved to: $filePath");

        // Verify file exists and has content
        if (await audioFile.exists() && await audioFile.length() > 0) {
          // Configure audio player
          await _audioPlayer.setReleaseMode(ReleaseMode.stop);
          await _audioPlayer.setSourceDeviceFile(audioFile.path);

          // Play the audio
          await _audioPlayer.resume();

          print("Audio playback started");
        } else {
          throw Exception("Generated audio file is empty or missing");
        }
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(
            "TTS API Error (${response.statusCode}): ${errorBody['error']?['message'] ?? 'Unknown error'}");
      }
    } catch (e, stackTrace) {
      print("Error in audio generation/playback: $e");
      print("Stack trace: $stackTrace");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to generate or play audio: ${e.toString()}"),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAudio = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Sign Language Recognition'),
        ),
        backgroundColor: const Color(0xFF12182A),
      ),
      backgroundColor: const Color(0xFF12182A),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sign Language Recognition Result:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.result.replaceFirst(
                      "The corrected text:", "The Depicted Text:"),
                  style: const TextStyle(fontFamily: 'MonospaceFont'),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingAudio
                        ? null
                        : () => _generateAndPlayAudio(widget.result),
                    icon: const Icon(Icons.volume_up, color: Colors.white),
                    label: Text(
                      _isLoadingAudio ? "Generating..." : "Voice the Text",
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3C83F7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
