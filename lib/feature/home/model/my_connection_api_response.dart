import 'my_connection_state_model.dart';

class MyConnectionApiResponse {
  final bool success;
  final String message;
  final ConnectionResult? result;

  MyConnectionApiResponse({
    required this.success,
    required this.message,
    this.result,
  });

  factory MyConnectionApiResponse.fromJson(Map<String, dynamic> json) {
    return MyConnectionApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      result: json['result'] != null ? ConnectionResult.fromJson(json['result']) : null,
    );
  }
}

class ConnectionResult {
  final List<MyConnectionStateModel> data;
  final Map<String, dynamic>? meta;

  ConnectionResult({required this.data, this.meta});

  factory ConnectionResult.fromJson(Map<String, dynamic> json) {
    return ConnectionResult(
      data: json['data'] != null
          ? (json['data'] as List).map((i) => MyConnectionStateModel.fromJson(i)).toList()
          : [],
      meta: json['meta'],
    );
  }
}