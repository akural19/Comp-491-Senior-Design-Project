import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class SignRecognitionService {
  static const String baseUrl =
      'https://sign-recognizer-ca63fe2f6b41.herokuapp.com';
  static const int maxRetries = 30;
  static const Duration retryDelay = Duration(seconds: 4);

  static Future<int> uploadVideo(File videoFile) async {
    int retryCount = 0;
    Exception? lastException;

    while (retryCount < maxRetries) {
      try {
        var request =
            http.MultipartRequest('POST', Uri.parse('$baseUrl/api/upload/'));

        var videoStream = http.ByteStream(videoFile.openRead());
        var length = await videoFile.length();

        var multipartFile = http.MultipartFile(
          'video',
          videoStream,
          length,
          filename: videoFile.path.split('/').last,
          contentType: MediaType('video', 'mp4'),
        );

        request.files.add(multipartFile);

        request.headers.addAll({
          'Accept': 'application/json',
          'Content-Type': 'multipart/form-data',
        });

        print('Sending request to: ${request.url}');
        print('Field name: video');
        print('File name: ${multipartFile.filename}');
        print('File size: $length bytes');
        print('Headers: ${request.headers}');

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
          Map<String, dynamic> responseData = json.decode(response.body);
          return responseData['id'];
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

  static Future<Map<String, dynamic>> getResult(int videoId) async {
    await Future.delayed(Duration(seconds: 8));
    String statusUrl = '$baseUrl/api/status/$videoId/';

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        http.Response response = await http.get(Uri.parse(statusUrl));
        if (response.statusCode == 200) {
          Map<String, dynamic> result = json.decode(response.body);

          if (result['status'] == 'completed') {
            return result;
          } else if (result['status'] == 'failed') {
            throw Exception(
                'Video processing failed: ${result['result'] ?? 'Unknown error'}');
          }

          print(
              'Video is being processed... Attempt ${attempt + 1}/$maxRetries');
          await Future.delayed(retryDelay);
        } else {
          print("Serkan bak buraya girdi");
          throw Exception('Request failed with status: ${response.statusCode}');
        }
      } catch (e) {
        print('Error getting result: $e');
        rethrow;
      }
    }

    throw TimeoutException('Video processing timed out');
  }
}
