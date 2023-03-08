import 'dart:io';

import 'package:app/services/core/api_response.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  final ApiResponse apiResponse = ApiResponse();
  ApiService({
    required this.baseUrl,
  });

  String _transformToEndPoint(dynamic endPoint) {
    switch (endPoint.runtimeType) {
      case String:
        return "/$endPoint";
      case List<String>:
        return (endPoint as List<String>).fold(
          "",
          (acc, curr) => "$acc/$curr",
        );
      default:
        throw Exception(
          "Endpoint: ${endPoint.toString()} is invalid.\nCheckout endPoint.",
        );
    }
  }

  Future<dynamic> fetch<T>({
    T? endpoint,
  }) async {
    final Uri parsedUri = Uri.parse(
      '$baseUrl${endpoint != null ? _transformToEndPoint(endpoint) : ''}',
    );
    try {
      await apiResponse.handleResponse(
        response: await http.get(parsedUri),
      );

      return apiResponse.data;
    } catch (e) {
      throw Exception(
        "ERROR in api_service $e",
      );
    }
  }

  Future<void> postImage<T>({
    required File image,
    required String fileName,
    T? endPoint,
  }) async {
    final Uri parsedUri = Uri.parse(
      '$baseUrl${endPoint != null ? _transformToEndPoint(endPoint) : ''}',
    );

    try {
      final request = http.MultipartRequest(
        'POST',
        parsedUri,
      );

      final fileLength = await image.length();
      final fileStream = http.ByteStream(
        image.openRead(),
      );
      final multipartFile = http.MultipartFile(
        'image',
        fileStream,
        fileLength,
        filename: fileName,
      );
      request.files.add(multipartFile);

      await apiResponse.handleResponse(
        response: await request.send(),
      );

      return apiResponse.data;
    } catch (e) {
      throw Exception(
        "ERROR in api_service $e",
      );
    }
  }
}
