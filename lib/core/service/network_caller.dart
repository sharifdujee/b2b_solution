

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'app_logger.dart';
import 'auth_service.dart';
import 'model/response_data.dart';




class NetworkCaller {
  /// it's 10, due to network issues increase time
  final int timeoutDuration = 50;

  Future<ResponseData> getRequest(String endpoint, {String? token}) async {
    AppLoggerHelper.info('GET Request: $endpoint');
    try {
      final Response response = await get(
        Uri.parse(endpoint),
        headers: {
          'Authorization': token ?? 'Bearer ${AuthService.token}',
          'Content-type': 'application/json',
        },
      ).timeout(Duration(seconds: timeoutDuration));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ResponseData> postRequest(String endpoint,
      {Map<String, dynamic>? body, String? token}) async {
    AppLoggerHelper.info('POST Request: $endpoint');
    AppLoggerHelper.info('Request Body: ${jsonEncode(body.toString())}');

    try {
      final Response response = await post(
        Uri.parse(endpoint),
        headers: {
          'Authorization': token ?? 'Bearer ${AuthService.token}',
          'Content-type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(Duration(seconds: timeoutDuration));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ResponseData> postImageRequest(String url, {required File file, required String token}) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['Authorization'] = token;
    request.files.add(await http.MultipartFile.fromPath('pickImage', file.path));

    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    return ResponseData(
        statusCode: response.statusCode,
        isSuccess: response.statusCode == 201,
        responseData: jsonDecode(responseData),
        errorMessage: ""
    );
  }



  Future<ResponseData> putRequest(String endpoint,
      {Map<String, dynamic>? body, String? token}) async {
    AppLoggerHelper.info('PUT Request: $endpoint');
    AppLoggerHelper.info('Request Body: ${jsonEncode(body.toString())}');

    try {
      final Response response = await put(
        Uri.parse(endpoint),
        headers: {
          'Authorization': token ?? 'Bearer ${AuthService.token}',
          'Content-type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(Duration(seconds: timeoutDuration));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }


  Future<ResponseData> patchRequest(String endpoint,
      {Map<String, dynamic>? body, String? token}) async {
    AppLoggerHelper.info('PATCH Request: $endpoint');
    AppLoggerHelper.info('Request Body: ${jsonEncode(body.toString())}');

    try {
      final Response response = await patch(
        Uri.parse(endpoint),
        headers: {
          'Authorization': token ?? 'Bearer ${AuthService.token}',
          'Content-type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(Duration(seconds: timeoutDuration));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ResponseData> deleteRequest(String endpoint,String? token, {Map<String, dynamic>? body,}) async {
    AppLoggerHelper.info('DELETE Request: $endpoint');
    try {
      final Response response = await delete(
          Uri.parse(endpoint),
          headers: {
            'Authorization': token ?? '${AuthService.token}',
            'Content-type': 'application/json',
          },
          body: jsonEncode(body)
      ).timeout(Duration(seconds: timeoutDuration));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Handle the response from the server
  Future<ResponseData> _handleResponse(http.Response response) async {
    AppLoggerHelper.info('Response Status: ${response.statusCode}');
    AppLoggerHelper.info('Response Body: ${response.body}');

    dynamic decodedResponse;
    try {
      if (response.body.isNotEmpty) {
        decodedResponse = jsonDecode(response.body);
      } else {
        decodedResponse = null;
      }
    } catch (e) {
      // If JSON parsing fails, keep raw body as string for debugging
      decodedResponse = response.body;
    }

    final int statusCode = response.statusCode;

    switch (statusCode) {
      case 200:
      case 201:
        return ResponseData(
          isSuccess: true,
          statusCode: statusCode,
          errorMessage: '',
          responseData: decodedResponse, // Always provide data
        );

      case 204:
        return ResponseData(
          isSuccess: true,
          statusCode: statusCode,
          errorMessage: '',
          responseData: null, // 204 No Content – expected
        );

      case 400:
      case 401:
      case 403:
      case 404:
      case 422:
      case 429:
      case 500:
      case 503:
      // For all error cases: mark as failed, but pass the full parsed body
        String fallbackMessage = _getFallbackErrorMessage(statusCode);

        return ResponseData(
          isSuccess: false,
          statusCode: statusCode,
          errorMessage: fallbackMessage,
          responseData: decodedResponse, // ← Critical: now contains message, errorMessages, etc.
        );

      default:
        return ResponseData(
          isSuccess: false,
          statusCode: statusCode,
          errorMessage: 'An unexpected error occurred.',
          responseData: decodedResponse,
        );
    }
  }

  /// Helper to provide sensible fallback messages (used only if controller doesn't extract from responseData)
  String _getFallbackErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Unauthorized. Please log in again.';
      case 403:
        return 'Access forbidden.';
      case 404:
        return 'Resource not found.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'Something went wrong.';
    }
  }

  // Handle errors during the request process
  ResponseData _handleError(dynamic error) {
    log('Request Error: $error');

    if (error is TimeoutException) {
      return ResponseData(
        isSuccess: false,
        statusCode: 408,
        errorMessage:
        'Request timed out. Please check your internet connection and try again.',
        responseData: null,
      );
    } else if (error is http.ClientException) {
      return ResponseData(
        isSuccess: false,
        statusCode: 500,
        errorMessage:
        'Network error occurred. Please check your connection and try again.',
        responseData: null,
      );
    } else {
      return ResponseData(
        isSuccess: false,
        statusCode: 500,
        errorMessage: 'Unexpected error occurred. Please try again later.',
        responseData: null,
      );
    }
  }
}