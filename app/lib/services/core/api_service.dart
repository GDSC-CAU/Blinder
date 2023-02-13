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
      apiResponse.handleResponse(
        response: await http.get(parsedUri),
      );

      return apiResponse.data;
    } catch (e) {
      throw Exception(
        "ERROR in api_service $e",
      );
    }
  }
}
