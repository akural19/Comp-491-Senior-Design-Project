import 'package:camera/camera.dart';
import 'package:comp_499_senior_project/video_preview_page.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoRecordingPage extends StatefulWidget {
  const VideoRecordingPage({Key? key}) : super(key: key);

  @override
  State<VideoRecordingPage> createState() => _VideoRecordingPageState();
}

class _VideoRecordingPageState extends State<VideoRecordingPage> {
  CameraController? _cameraController;
  bool _isRecording = false; // Track recording state
  XFile? _recordedVideo; // Store recorded video file
  List<CameraDescription>? _cameras; // List of available cameras
  int _currentCameraIndex = 0; // Index of the currently selected camera

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndInitializeCamera();
  }

  /// Check Permissions and Initialize Camera
  Future<void> _checkPermissionsAndInitializeCamera() async {
    final cameraStatus = await Permission.camera.request();
    final microphoneStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && microphoneStatus.isGranted) {
      _initializeCameras();
    } else {
      if (cameraStatus.isPermanentlyDenied ||
          microphoneStatus.isPermanentlyDenied) {
        _showPermissionSettingsSnackBar();
      } else {
        _showSnackBar("Camera and Microphone permissions are required.");
      }

      Navigator.of(context).pop(); // Go back to the previous screen
    }
  }

  /// Initialize Cameras
  Future<void> _initializeCameras() async {
    try {
      _cameras = await availableCameras(); // Fetch all available cameras
      _initializeCamera(_cameras![_currentCameraIndex]);
    } catch (e) {
      _showSnackBar("Failed to initialize cameras.");
    }
  }

  /// Initialize Selected Camera
  Future<void> _initializeCamera(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
    );

    await _cameraController!.initialize();
    setState(() {});
  }

  /// Switch Camera
  /*
  void _switchCamera() {
    if (_cameras == null || _cameras!.isEmpty) return;

    // Toggle between front and back cameras
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;
    _initializeCamera(_cameras![_currentCameraIndex]);
  }
   */
  /// Switch Camera
  Future<void> _switchCamera() async {
    if (_isRecording) {
      // Prevent switching while recording
      _showSnackBar("Stop recording before switching cameras.");
      return;
    }

    if (_cameras == null || _cameras!.isEmpty) return;

    // Toggle between front and back cameras
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;
    await _initializeCamera(_cameras![_currentCameraIndex]);
  }

  /// Start or Stop Recording
  Future<void> _startOrStopRecording() async {
    if (_cameraController == null) return;

    if (_isRecording) {
      // Stop Recording
      final videoFile = await _cameraController!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _recordedVideo = videoFile; // Store recorded video
      });

      _navigateToVideoPreview(videoFile.path); // Navigate to video preview
    } else {
      // Start Recording
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          "${directory.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4";

      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });

      _showSnackBar("Recording started...");
    }
  }

  /// Navigate to Video Preview Screen
  void _navigateToVideoPreview(String videoPath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPreviewPage(videoPath: videoPath),
      ),
    );
  }

  /// Show SnackBar for Permission Denied
  void _showPermissionSettingsSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Camera and Microphone permissions are permanently denied. Please enable them in app settings.",
        ),
        action: SnackBarAction(
          label: "Settings",
          onPressed: () {
            openAppSettings(); // Opens the app settings
          },
        ),
      ),
    );
  }

  /// Show SnackBar for Other Messages
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  /*
  @override
  Widget build(BuildContext context) {
    final isInitialized =
        _cameraController != null && _cameraController!.value.isInitialized;

    return Scaffold(
      body: Stack(
        children: [
          // Camera Preview
          if (isInitialized)
            CameraPreview(_cameraController!)
          else
            const Center(child: CircularProgressIndicator()),

          // Back Button
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5.00, 25.00, 5.00, 25.00),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Navigate back to the main page
                },
              ),
            ),
          ),

          // Record Button
          if (isInitialized)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: GestureDetector(
                  onTap: _startOrStopRecording,
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: _isRecording ? Colors.red : Colors.green,
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.videocam,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

          // Front-Back Camera Switch Button
          if (isInitialized)
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 34.0, right: 34.0),
                child: FloatingActionButton(
                  onPressed: _switchCamera,
                  mini: true,
                  backgroundColor: Colors.grey[800],
                  child: const Icon(Icons.cameraswitch, color: Colors.white),
                ),
              ),
            ),

          // Overlay: Save Location (optional, displayed briefly)

          /*
          if (_recordedVideo != null)
            Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  "Saved: ${_recordedVideo!.path}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
           */
        ],
      ),
    );
  }
   */

  @override
  Widget build(BuildContext context) {
    final isInitialized =
        _cameraController != null && _cameraController!.value.isInitialized;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: size.width,
                  height: size.width * _cameraController!.value.aspectRatio,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),

          // Back Button with proper padding for status bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Bottom Controls
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100,
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(width: 60), // Space for symmetry

                  // Record Button
                  GestureDetector(
                    onTap: _startOrStopRecording,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        color: _isRecording ? Colors.red : Colors.white,
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.videocam,
                        size: 40,
                        color: _isRecording ? Colors.white : Colors.black,
                      ),
                    ),
                  ),

                  // Camera Switch Button
                  Container(
                    width: 60,
                    alignment: Alignment.center,
                    child: IconButton(
                      onPressed: _switchCamera,
                      icon: const Icon(
                        Icons.cameraswitch,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
