import 'dart:convert';
import 'dart:io';

import 'package:comp_499_senior_project/sign_recognition_result.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

import 'sign_recognition_service.dart';

class VideoPreviewPage extends StatefulWidget {
  final String videoPath;

  const VideoPreviewPage({Key? key, required this.videoPath}) : super(key: key);

  @override
  State<VideoPreviewPage> createState() => _VideoPreviewPageState();
}

class _VideoPreviewPageState extends State<VideoPreviewPage> {
  late VideoPlayerController _videoPlayerController;
  bool _isUploading = false;
  bool _isProcessing = false;

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

  /*
  Future<void> _uploadVideo() async {
    setState(() {
      _isUploading = true;
    });

    try {
      // Show upload progress dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Dialog(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Uploading video and processing...',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            );
          },
        );
      }

      // Upload video and get result
      final result =
          await SignRecognitionService.uploadVideo(File(widget.videoPath));

      // Close progress dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to result screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SignRecognitionResult(result: result),
          ),
        );
      }
    } catch (e) {
      // Close progress dialog if open
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
   */

  Future<void> _uploadVideo() async {
    setState(() {
      _isUploading = true;
    });

    try {
      // Show upload progress dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Dialog(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Uploading video and processing...',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            );
          },
        );
      }

      // Upload video and get result
      int videoId =
          await SignRecognitionService.uploadVideo(File(widget.videoPath));
      Map<String, dynamic> result =
          await SignRecognitionService.getResult(videoId);

      // Close progress dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to result screen
      _displaySignLanguageRecognitionResult(result);
    } catch (e) {
      // Close progress dialog if open
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  /*
  Future<void> _displaySignLanguageRecognitionResult(
      Map<String, dynamic> result) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Show progress dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Dialog(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      'Processing video...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }

      // Display the sign language recognition result
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Sign Language Recognition Result'),
              content: Text(
                result['result'] ?? 'null',
                style: const TextStyle(fontFamily: 'MonospaceFont'),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Close the progress dialog if open
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show an error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
  */

  Future<void> _displaySignLanguageRecognitionResult(
      Map<String, dynamic> result) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Show progress dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Dialog(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      'Processing video...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
      // Fetch the GPT API response
      String correctedText = await _fetchGPTResponse(result['result']);
      // Navigate to the new SignLanguageRecognitionResultPage
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SignLanguageRecognitionResultPage(
              videoPath: widget.videoPath,
              result: correctedText,
            ),
          ),
        );
      }
    } catch (e) {
      // Close the progress dialog if open
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show an error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<String> _fetchGPTResponse(String text) async {
    final apiKey =
        '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';
    final apiUrl = 'https://api.openai.com/v1/chat/completions';

    try {
      // Build the request payload
      final requestBody = jsonEncode({
        "model": "gpt-4",
        "messages": [
          {
            "role": "system",
            "content":
                "You are an expert in converting sign language videos to text. I will provide you with text extracted from a sign language video using our model. The model has some deficiencies, and your task is to identify and correct any mistakes based on the context while strictly maintaining the letter count of the original text. Specifically, our model may confuse the letters 'i' and 'j'—sometimes it outputs the correct letter, and other times it does not. Your responsibility is to review the text carefully and determine the correct letter based on the context while ensuring the total number of characters in each word remains unchanged. If null or no hand is detected, do not do anything and return the same input as output."
          },
          {"role": "user", "content": "The text for correction: $text"}
        ],
        "max_tokens": 100,
        "temperature": 0.5,
      });

      // Make the POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: requestBody,
      );

      // Handle the response
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final reply = responseBody['choices'][0]['message']['content'].trim();
        return reply;
      } else {
        throw Exception(
            "Failed to fetch GPT response: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      throw Exception("Error in GPT request: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[800], // Updated to match home page
      appBar: AppBar(
        backgroundColor: Colors.grey[800], // Updated to match home page
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Video Preview",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold, // Match home page style
          ),
        ),
      ),
      body: Column(
        children: [
          // Video Preview Section
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Video Container
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: size.width,
                      maxHeight: size.height,
                    ),
                    child: AspectRatio(
                      aspectRatio: _videoPlayerController.value.aspectRatio,
                      child: _videoPlayerController.value.isInitialized
                          ? VideoPlayer(_videoPlayerController)
                          : const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),

                // Play Button
                Positioned(
                  right: 20,
                  bottom: 20,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700, // Updated to match home page
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          if (_videoPlayerController.value.isPlaying) {
                            _videoPlayerController.pause();
                          } else {
                            _videoPlayerController.play();
                          }
                        });
                      },
                      icon: Icon(
                        _videoPlayerController.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Buttons with minimal padding
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                // Discard Button
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400, // Updated color
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              10), // Match home page style
                        ),
                      ),
                      icon: const Icon(Icons.delete, color: Colors.white),
                      label: const Text(
                        "Discard",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold, // Match home page style
                        ),
                      ),
                    ),
                  ),
                ),
                // Upload Button
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ElevatedButton.icon(
                      onPressed: _isUploading ? null : _uploadVideo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.blue.shade700, // Updated to match home page
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              10), // Match home page style
                        ),
                      ),
                      icon: const Icon(Icons.cloud_upload, color: Colors.white),
                      label: Text(
                        _isUploading ? "Uploading..." : "Upload & Process",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold, // Match home page style
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
