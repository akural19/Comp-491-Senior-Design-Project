import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

class SignRecognitionService {
  static const String baseUrl =
      'https://sign-recognizer-ca63fe2f6b41.herokuapp.com';
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 3);

  static Future<String> uploadVideo(File videoFile) async {
    int retryCount = 0;
    Exception? lastException;

    while (retryCount < maxRetries) {
      try {
        // Create multipart request with the correct endpoint
        var request =
            http.MultipartRequest('POST', Uri.parse('$baseUrl/api/upload/'));

        // Add file to request
        var videoStream = http.ByteStream(videoFile.openRead());
        var length = await videoFile.length();

        // Create the multipart file with the correct field name 'video'
        var multipartFile = http.MultipartFile(
            'video', // Field name changed to 'video'
            videoStream,
            length,
            filename: videoFile.path.split('/').last);

        request.files.add(multipartFile);

        // Add necessary headers
        request.headers.addAll({
          'Accept': '*/*',
          'Content-Type': 'multipart/form-data',
        });

        print('Sending request to: ${request.url}');
        print('Field name: video');
        print('File name: ${multipartFile.filename}');
        print('File size: $length bytes');
        print('Headers: ${request.headers}');

        // Send request with timeout
        var streamedResponse = await request.send().timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            throw TimeoutException('Request timed out');
          },
        );

        print('Response status: ${streamedResponse.statusCode}');
        var response = await http.Response.fromStream(streamedResponse);
        print('Response headers: ${response.headers}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          return response.body;
        } else {
          throw Exception(
              'Server returned status code: ${response.statusCode}\nResponse: ${response.body}');
        }
      } catch (e) {
        print('Attempt ${retryCount + 1} failed: $e');
        lastException = e as Exception;
        retryCount++;

        if (retryCount < maxRetries) {
          print(
              'Waiting ${retryDelay.inSeconds * retryCount} seconds before retry...');
          await Future.delayed(retryDelay * retryCount);
          continue;
        }
      }
    }

    throw Exception(
        'Failed after $maxRetries attempts. Last error: $lastException');
  }
}
