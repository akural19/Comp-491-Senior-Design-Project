/*
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

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
  late VideoPlayerController _videoPlayerController;
  late AudioPlayer _audioPlayer;
  bool _isLoadingAudio = false;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
      })
      ..setLooping(true);
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  /*
  Future<void> _generateAndPlayAudio(String text) async {
    setState(() {
      _isLoadingAudio = true;
    });

    try {
      final apiKey =
          "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"; // Replace with your OpenAI API key
      final apiUrl = "https://api.openai.com/v1/audio/tts";

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
        throw Exception("Failed to generate audio: ${response.body}");
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

  Future<void> _generateAndPlayAudio(String text) async {
    setState(() {
      _isLoadingAudio = true;
    });

    try {
      final apiKey =
          "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"; // Replace with your OpenAI API key
      final apiUrl = "https://api.openai.com/v1/audio/speech";

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
      // Handle errors and display the message
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
        title: const Text('Sign Language Recognition Result'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: AspectRatio(
                  aspectRatio: _videoPlayerController.value.aspectRatio,
                  child: _videoPlayerController.value.isInitialized
                      ? VideoPlayer(_videoPlayerController)
                      : const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sign Language Recognition Result:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.result,
                  style: const TextStyle(fontFamily: 'MonospaceFont'),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _isLoadingAudio
                      ? null
                      : () => _generateAndPlayAudio(widget.result),
                  icon: const Icon(Icons.volume_up),
                  label: Text(
                      _isLoadingAudio ? "Generating..." : "Voice the Text"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/

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
      text.split(':').last.trim();
    }
    try {
      final apiKey =
          "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"; // Replace with your OpenAI API key
      final apiUrl = "https://api.openai.com/v1/audio/speech";

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
        print("serkan seslendirilen text $text");
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
      ),
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
              widget.result,
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
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
