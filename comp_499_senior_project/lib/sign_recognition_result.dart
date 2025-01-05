/*
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
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

  Future<void> _generateAndPlayAudio(String text) async {
    setState(() {
      _isLoadingAudio = true;
    });

    if (text.contains(':')) {
      // Split the input string at the colon and return the second part (trimmed)
      text = text.split(':').last.trim();
    }
    try {
      final apiKey =
          "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"; // Replace with your OpenAI API key
      final apiUrl = "https://api.openai.com/v1/audio/speech";
      await Future.delayed(Duration(seconds: 2));
      // Prepare the HTTP POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "tts-1",
          "voice": "alloy",
          "input": text,
        }),
      );
      print("Seslendirilen text final: $text");
      if (response.statusCode == 200) {
        // Save the audio file locally
        final bytes = response.bodyBytes;
        final dir = await getTemporaryDirectory();
        final filePath = "${dir.path}/generated_audio.mp3";
        final audioFile = File(filePath);
        await audioFile.writeAsBytes(bytes);

        // Play the audio file
        await _audioPlayer.play(DeviceFileSource(audioFile.path));
      } else {
        // Handle API errors
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['error'] != null
            ? responseBody['error']['message']
            : 'Unknown error occurred';
        throw Exception("Failed to generate audio: $errorMessage");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoadingAudio = false;
      });
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
              widget.result
                  .replaceFirst("The corrected text:", "The Depicted Text:"),
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
    );
  }
}

 */

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
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

  /*
  String _generateFileName(String text) {
    // Simple way to generate a unique filename based on text content
    final cleanText = text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    return "audio_${cleanText.substring(0, min(50, cleanText.length))}.mp3";
  }

  Future<String?> _getExistingAudioPath(String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/$fileName");
    if (await file.exists()) {
      return file.path;
    }
    return null;
  }


  Future<void> _generateAndPlayAudio(String text) async {
    setState(() {
      _isLoadingAudio = true;
    });

    if (text.contains(':')) {
      text = text.split(':').last.trim();
    }

    try {
      // Generate filename based on text content
      final fileName = _generateFileName(text);

      // Check if we already have this audio file
      final existingPath = await _getExistingAudioPath(fileName);

      if (existingPath != null) {
        // Use existing audio file
        print("Using cached audio file for: $text");
        await _audioPlayer.play(DeviceFileSource(existingPath));
      } else {
        final apiKey =
            "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";
        final apiUrl = "https://api.openai.com/v1/audio/speech";
        await Future.delayed(Duration(seconds: 2));

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            "Authorization": "Bearer $apiKey",
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "model": "tts-1",
            "voice": "nova",
            "input": "The depicted text is alphabet",
            "format": "mp3",
          }),
        );
        print("Seslendirilen text final: $text");

        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          final dir = await getTemporaryDirectory();
          final filePath = "${dir.path}/$fileName";
          final audioFile = File(filePath);
          await audioFile.writeAsBytes(bytes);

          await Future.delayed(Duration(seconds: 2));
          await _audioPlayer.play(DeviceFileSource(audioFile.path));
        } else {
          final responseBody = jsonDecode(response.body);
          final errorMessage = responseBody['error'] != null
              ? responseBody['error']['message']
              : 'Unknown error occurred';
          throw Exception("Failed to generate audio: $errorMessage");
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoadingAudio = false;
      });
    }
  }
   */

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

      final apiKey =
          "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";
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
