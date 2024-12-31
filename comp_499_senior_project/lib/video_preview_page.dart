import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'sign_recognition_result.dart';
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

    int retryCount = 0;
    try {
      // Show upload progress dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: Dialog(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      StatefulBuilder(
                        builder: (context, setState) {
                          String message = 'Uploading video and processing...';
                          if (retryCount > 0) {
                            message +=
                                '\nRetry attempt $retryCount of ${SignRecognitionService.maxRetries}';
                          }
                          return Text(
                            message,
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                    ],
                  ),
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

      // Show error message with retry option
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Upload Error'),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _uploadVideo(); // Retry upload
                  },
                  child: const Text('Retry'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  /*
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Preview"),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _videoPlayerController.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _videoPlayerController.value.aspectRatio,
                        child: VideoPlayer(_videoPlayerController),
                      )
                    : const Center(child: CircularProgressIndicator()),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                  horizontal: screenWidth * 0.05,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text("Discard"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize:
                            Size(screenWidth * 0.35, screenHeight * 0.06),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : _uploadVideo,
                      icon: const Icon(Icons.cloud_upload),
                      label: Text(
                          _isUploading ? "Uploading..." : "Upload & Process"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize:
                            Size(screenWidth * 0.35, screenHeight * 0.06),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: screenHeight * 0.12,
            right: screenWidth * 0.05,
            child: FloatingActionButton(
              onPressed: () {
                if (_videoPlayerController.value.isPlaying) {
                  _videoPlayerController.pause();
                } else {
                  _videoPlayerController.play();
                }
                setState(() {});
              },
              backgroundColor: Colors.purple,
              child: Icon(
                _videoPlayerController.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
            ),
          ),
        ],
      ),
    );
  }
   */

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
