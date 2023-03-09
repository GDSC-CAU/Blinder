import 'dart:convert';

import 'package:http/http.dart';

enum Status {
  success,
  clientError,
  serverError,
  unknownError,
  redirection,
  pending,
}

class ApiResponse {
  Status status = Status.pending;
  dynamic data;
  int? statusCode;

  dynamic _transformResponseToJson(String jsonString) => jsonDecode(jsonString);

  int _getResponseCodeNumber({
    required int number,
  }) =>
      int.parse("$number".split("")[0]);

  Future<void> handleResponse<T extends BaseResponse>({
    required T response,
  }) async {
    statusCode = response.statusCode;
    final statusCodeInitialNumber = _getResponseCodeNumber(
      number: response.statusCode,
    );

    switch (statusCodeInitialNumber) {
      case 1:
        status = Status.pending;
        break;
      case 2:
        status = Status.success;
        if (response is Response) {
          data = _transformResponseToJson(
            response.body,
          );
        }
        if (response is StreamedResponse) {
          data = _transformResponseToJson(
            await response.stream.bytesToString(),
          );
        }
        break;
      case 3:
        data = null;
        status = Status.redirection;
        break;
      case 4:
        data = null;
        status = Status.clientError;
        break;
      case 5:
        data = null;
        status = Status.serverError;
        break;
      default:
        data = null;
        status = Status.unknownError;
        break;
    }
  }
}
