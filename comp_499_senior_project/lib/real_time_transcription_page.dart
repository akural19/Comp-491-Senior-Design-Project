import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class RealTimeTranscriptionPage extends StatefulWidget {
  const RealTimeTranscriptionPage({super.key});

  @override
  _RealTimeTranscriptionPageState createState() =>
      _RealTimeTranscriptionPageState();
}

class _RealTimeTranscriptionPageState extends State<RealTimeTranscriptionPage> {
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _transcription = "";
  //List<String> _transcriptionSegments = [];
  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
  }

  Future<void> _startListening() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) {
        print('Status: $status');
        if (status == 'notListening') {
          // Restart listening automatically if it stops

          if (_isListening) {
            _startListening();
          }
        } else if (status == 'done') {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (error) {
        print('Error: ${error.errorMsg}');
        setState(() {
          _isListening = false;
          _transcription = "Error occurred: ${error.errorMsg}";
        });
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
        _transcription = ""; // Clear previous transcription
      });
      _speechToText.listen(
        onResult: (result) {
          setState(() {
            _transcription = result.recognizedWords;
          });
        },
        listenMode: stt.ListenMode.dictation,
        pauseFor: const Duration(seconds: 10),
        partialResults: true,
      );
    } else {
      setState(() {
        _isListening = false;
        _transcription = "Speech recognition not available.";
      });
    }
  }

  void _stopListening() {
    _speechToText.stop();
    setState(() => _isListening = false);
  }

  @override
  void dispose() {
    _speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Real-Time Transcription",
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Transcription Text

            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _transcription.isEmpty
                      ? "Press the button and start speaking!"
                      : _transcription,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),

            /*
            Expanded(
              child: ListView.builder(
                itemCount: _transcriptionSegments.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      '${index + 1}. ${_transcriptionSegments[index]}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                },
              ),
            ),

             */
            // Floating Action Button
            Align(
              alignment: Alignment.bottomCenter,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double buttonSize =
                      constraints.maxWidth * 0.2; // 20% of the screen width
                  return SizedBox(
                    width: buttonSize,
                    height: buttonSize,
                    child: FloatingActionButton(
                      onPressed:
                          _isListening ? _stopListening : _startListening,
                      backgroundColor:
                          _isListening ? Colors.red : const Color(0xFF3C83F7),
                      child: Icon(
                        _isListening ? Icons.mic_off : Icons.mic,
                        size:
                            buttonSize * 0.4, // Icon size is 40% of button size
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
