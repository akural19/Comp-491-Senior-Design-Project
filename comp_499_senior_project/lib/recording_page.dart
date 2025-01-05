import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:comp_499_senior_project/transcription_in_progress_screen.dart';
import 'package:comp_499_senior_project/transcription_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordingPage extends StatefulWidget {
  const RecordingPage({super.key});

  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage>
    with SingleTickerProviderStateMixin {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false; // Tracks if recording is active
  String? _recordingPath; // Path to save the recorded file
  int _recordingDuration = 0; // Timer for recording duration
  Timer? _timer;
  bool _isPolling = false;
  String? apiKey = dotenv.env['TRANSKRIPTOR_API_KEY'];

  late AnimationController _animationController;
  bool _isTranscribing = false;
  String _selectedLanguage = "tr-TR";

  String orderId = "";
  late File file;
  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _initializeAnimationController();
  }

  Future<void> _initializeAnimationController() async {
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _initializeRecorder() async {
    try {
      await _recorder.openRecorder();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Issue in recorder opening!!!"),
        ),
      );
      return;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<bool> _requestPermissions() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  void _startOrPauseRecording() async {
    if (_isRecording) {
      // Pause recording
      await _recorder.pauseRecorder();
      _timer?.cancel();
      _animationController.stop();
    } else {
      // Request permissions
      final hasPermission = await _requestPermissions();
      print("Microphone Permission Status: $hasPermission");
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Microphone permission is required to record audio."),
          ),
        );
        return;
      }

      // Start or resume recording
      if (_recorder.isPaused) {
        // Resume recording
        await _recorder.resumeRecorder();
      } else {
        // Start recording
        final directory = await getApplicationDocumentsDirectory();
        _recordingPath ??=
            "${directory.path}/recording.${Platform.isIOS ? 'm4a' : 'wav'}";
        //_recordingPath ??= "${directory.path}/recording.wav";

        await _recorder.startRecorder(
          toFile: _recordingPath,
          codec: Platform.isIOS ? Codec.aacMP4 : Codec.pcm16WAV,
          bitRate: Platform.isIOS ? 64000 : 16000,
          sampleRate: 44100,
        );
      }

      _startTimer();
      _animationController.repeat(reverse: true);
    }

    setState(() {
      _isRecording = !_isRecording;
    });
  }

  void _stopAndTranscribe() async {
    // Stop recording
    await _recorder.stopRecorder();
    _timer?.cancel();

    setState(() {
      _isRecording = false;
      _recordingDuration = 0;
    });

    // Show progress indicator while saving the file

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent closing dialog during processing
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: const Color(0xFF12182A),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Wrap content
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center content vertically
                children: [
                  CircularProgressIndicator(),
                  const SizedBox(
                      height:
                          16), // Add spacing between progress indicator and text
                  const Text(
                    "File is saving. Please wait...",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center, // Center align text
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    // Wait for the file to be saved

    await Future.delayed(const Duration(seconds: 8));
    // Ensure the file exists and is saved
    if (_recordingPath != null) {
      file = File(_recordingPath!);
      if (await file.exists()) {
        //print(_recordingPath);
        if (mounted) Navigator.of(context).pop();
        _showLanguageDialog();
        //_uploadAndTranscribe(file, _selectedLanguage);
      } else {
        if (mounted) {
          Navigator.of(context).pop(); // Close progress dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Recording file not found.")),
          );
        }
      }
    } else {
      if (mounted) {
        Navigator.of(context).pop(); // Close progress dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("No recording available to transcribe.")),
        );
      }
    }
  }

  void _startTimer() {
    final stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        _recordingDuration = stopwatch.elapsedMilliseconds;
      });
    });
  }

  String _formatDuration(int milliseconds) {
    final minutes = (milliseconds ~/ 60000).toString().padLeft(2, '0');
    final seconds = ((milliseconds % 60000) ~/ 1000).toString().padLeft(2, '0');
    final millis = ((milliseconds % 1000) ~/ 10).toString().padLeft(2, '0');
    return "$minutes:$seconds.$millis";
  }

  Future<void> _uploadAndTranscribe(File file, String language) async {
    try {
      final isIOS = Platform.isIOS;
      final contentType = isIOS ? 'audio/m4a' : 'audio/wav';
      final fileName = isIOS ? 'recording.m4a' : 'recording.wav';
      // Step 1: Obtain Upload URL
      final url = Uri.parse(
          'https://api.tor.app/developer/transcription/local_file/get_upload_url');
      final request = await HttpClient().postUrl(url);
      request.headers
        ..set('Content-Type', 'application/json')
        ..set('Authorization', 'Bearer $apiKey');
      request.add(utf8.encode(jsonEncode({'file_name': fileName})));

      final response = await request.close();
      if (response.statusCode == 200) {
        final jsonResponse = await response.transform(utf8.decoder).join();
        final data = jsonDecode(jsonResponse);
        final uploadUrl = data['upload_url'];
        final publicUrl = data['public_url'];

        // Step 2: Upload the File
        final uploadRequest = await HttpClient().putUrl(Uri.parse(uploadUrl));
        uploadRequest.headers.set('Content-Type', contentType);
        final fileBytes = await file.readAsBytes();
        uploadRequest.headers.set('Content-Length',
            fileBytes.length.toString()); // Set Content-Length
        uploadRequest.add(fileBytes);
        final uploadResponse = await uploadRequest.close();

        if (uploadResponse.statusCode == 200) {
          print("File uploaded succesfully. ");
          // Step 3: Initiate Transcription
          await _initiateTranscription(publicUrl, language);
        } else {
          print('File upload failed');
          print(await uploadResponse.transform(utf8.decoder).join());
          print('File exists: ${await file.exists()}');
          print('File size: ${await file.length()}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("File upload failed.")),
          );
        }
      } else {
        print('Failed to get upload URL');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to get upload URL.")),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  Future<void> _initiateTranscription(String publicUrl, String language) async {
    try {
      final transcriptionUrl = Uri.parse(
          'https://api.tor.app/developer/transcription/local_file/initiate_transcription');
      final transcriptionRequest = await HttpClient().postUrl(transcriptionUrl);
      transcriptionRequest.headers.set('Authorization', 'Bearer $apiKey');
      transcriptionRequest.add(utf8.encode(jsonEncode({
        'url': publicUrl,
        'language': language,
        'service': 'Standard',
      })));

      final transcriptionResponse = await transcriptionRequest.close();
      if (transcriptionResponse.statusCode == 202) {
        final transcriptionJson =
            await transcriptionResponse.transform(utf8.decoder).join();
        final data = jsonDecode(transcriptionJson);
        setState(() {
          orderId = data['order_id'];
        });

        print('Transcription initiated. Order ID: $orderId');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Transcription initiated. Waiting for results...")),
        );

        // Poll for transcription results
        await _pollTranscriptionResults();
      } else {
        print('Failed to initiate transcription');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to initiate transcription.")),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  Future<String?> _pollTranscriptionResults() async {
    if (orderId == "") {
      print('Order ID is null.');
      throw Exception("Order ID is missing.");
    }
    final resultsUrl =
        Uri.parse('https://api.tor.app/developer/files/$orderId/content');
    const maxRetries =
        12; // Maximum retries (e.g., 12 retries = 1 minute polling)
    const retryDelay = Duration(seconds: 4); // Delay between retries
    int retryCount = 0;

    if (_isPolling) {
      print('Polling already in progress. Skipping...');
      return null;
    }
    _isPolling = true;

    try {
      while (retryCount < maxRetries) {
        final resultRequest = await HttpClient().getUrl(resultsUrl);
        resultRequest.headers.set('Authorization', 'Bearer $apiKey');

        final resultResponse = await resultRequest.close();
        if (resultResponse.statusCode == 200) {
          final resultJson =
              await resultResponse.transform(utf8.decoder).join();
          final resultData = jsonDecode(resultJson);

          if (resultData['status'] == 'Completed') {
            final content = resultData['content'] as List<dynamic>;
            final transcriptionText =
                content.map((entry) => entry['text']).join(' ');

            print('Transcription completed: $transcriptionText');
            return transcriptionText; // Return transcription result
          } else if (resultData['status'] == 'failed') {
            print('Transcription failed.');
            throw Exception("Transcription failed.");
          }
        }

        retryCount++;
        await Future.delayed(retryDelay); // Wait before retrying
      }

      throw Exception("Transcription timed out.");
    } catch (e) {
      print("Error during transcription polling: $e");
      rethrow; // Propagate the exception to handle it in `_startTranscription`
    } finally {
      _isPolling = false; // Reset polling flag
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Speech to Text Converter",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF12182A),
        centerTitle: true,
        elevation: 4,
      ),
      backgroundColor: const Color(0xFF12182A),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              _formatDuration(_recordingDuration).split('.')[0],
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text:
                              '.${_formatDuration(_recordingDuration).split('.')[1]}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (_animationController != null)
                    ScaleTransition(
                      scale: _animationController.isAnimating
                          ? Tween(begin: 1.0, end: 1.2).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: Curves.easeInOut,
                              ),
                            )
                          : AlwaysStoppedAnimation(1.0),
                      child: ElevatedButton(
                        onPressed: _startOrPauseRecording,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                          backgroundColor: _isRecording
                              ? Colors.red
                              : const Color(0xFF3C83F7),
                        ),
                        child: Icon(
                          _isRecording ? Icons.pause : Icons.mic,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Stop & Transcribe Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                _stopAndTranscribe();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3C83F7),
                padding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 30.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                //backgroundColor: Colors.blue,
                //padding: const EdgeInsets.symmetric(
                //vertical: 20.0, horizontal: 30.0),
              ),
              child: const Text(
                "Stop & Transcribe",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          String tempSelectedLanguage =
              _selectedLanguage; // Use current language as the default
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                backgroundColor: const Color(0xFF12182A),
                title: const Text("Select Language"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      value: tempSelectedLanguage,
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setDialogState(() {
                            tempSelectedLanguage =
                                newValue; // Update temporary selection
                          });
                        }
                      },
                      items: const [
                        DropdownMenuItem<String>(
                          value: "tr-TR",
                          child: Text("Turkish"),
                        ),
                        DropdownMenuItem<String>(
                          value: "en-US",
                          child: Text("English"),
                        ),
                        DropdownMenuItem<String>(
                          value: "fr-FR",
                          child: Text("French"),
                        ),
                        DropdownMenuItem<String>(
                          value: "de-DE",
                          child: Text("German"),
                        ),
                        DropdownMenuItem<String>(
                          value: "nl-NL",
                          child: Text("Dutch"),
                        ),
                        DropdownMenuItem<String>(
                          value: "ar-AR",
                          child: Text("Arabic"),
                        ),
                        DropdownMenuItem<String>(
                          value: "it-IT",
                          child: Text("Italian"),
                        ),
                        DropdownMenuItem<String>(
                          value: "es-ES",
                          child: Text("Spanish"),
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedLanguage =
                            tempSelectedLanguage; // Confirm and save selection
                      });
                      print("Selected language confirmed: $_selectedLanguage");
                      Navigator.of(context).pop(); // Close the dialog
                      _startTranscription(); // Start transcription with the selected language
                    },
                    child: const Text("Confirm"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // Close dialog without changing
                    },
                    child: const Text("Cancel"),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }

  Future<void> _startTranscription() async {
    if (!(await file.exists())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No valid recording file found.")),
      );
      return;
    }

    // Show the animation screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TranscriptionInProgressScreen(),
      ),
    );

    try {
      await _uploadAndTranscribe(file, _selectedLanguage);
      final transcriptionResult = await _pollTranscriptionResults();
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => TranscriptionResultScreen(
              transcriptionResult: transcriptionResult,
            ),
          ),
        );
      }
    } catch (e) {
      print("Error during transcription: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transcription failed.")),
        );
        Navigator.of(context).pop(); // Close animation screen on failure
      }
    } finally {
      setState(() {
        _isTranscribing = false;
      });
    }
  }
}
