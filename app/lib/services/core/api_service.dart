import 'package:app/models/model_factory.dart';
import 'package:app/services/core/api_response.dart';
import 'package:dio/dio.dart';
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

  Future<JsonMap?> postImage<T>({
    required String imagePath,
    required String imageKey,
    required String fileName,
    T? endPoint,
  }) async {
    final Uri parsedUri = Uri.parse(
      '$baseUrl${endPoint != null ? _transformToEndPoint(endPoint) : ''}',
    );

    try {
      final dio = Dio();

      final formData = FormData.fromMap({
        imageKey: await MultipartFile.fromFile(
          imagePath,
        ),
      });

      final response = await dio.postUri<Map<String, dynamic>>(
        parsedUri,
        data: formData,
      );

      return response.data;
    } catch (e) {
      throw Exception(
        "ERROR in api_service $e",
      );
    }
  }
}
