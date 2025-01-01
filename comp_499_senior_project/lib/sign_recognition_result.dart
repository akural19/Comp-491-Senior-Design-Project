import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SignLanguageRecognitionResultPage extends StatefulWidget {
  final String videoPath;
  final Map<String, dynamic> result;

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

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
      })
      ..setLooping(true);
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
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
                  widget.result['result'] ?? 'No result found',
                  style: const TextStyle(fontFamily: 'MonospaceFont'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
