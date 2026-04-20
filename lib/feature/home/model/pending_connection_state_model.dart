import 'dart:convert';

class PendingConnectionModel {
  final bool success;
  final String message;
  final ConnectionResult? result; // Nullable to handle error responses

  PendingConnectionModel({
    required this.success,
    required this.message,
    this.result,
  });

  factory PendingConnectionModel.fromJson(Map<String, dynamic> json) => PendingConnectionModel(
    success: json["success"] ?? false,
    message: json["message"] ?? "",
    result: json["result"] == null ? null : ConnectionResult.fromJson(json["result"]),
  );
}

class ConnectionResult {
  final List<PendingConnection> data;
  final ConnectionMeta? meta;

  ConnectionResult({
    required this.data,
    this.meta,
  });

  factory ConnectionResult.fromJson(Map<String, dynamic> json) => ConnectionResult(
    data: json["data"] == null
        ? []
        : List<PendingConnection>.from(json["data"].map((x) => PendingConnection.fromJson(x))),
    meta: json["meta"] == null ? null : ConnectionMeta.fromJson(json["meta"]),
  );
}

class PendingConnection {
  final String id;
  final String senderId;
  final String receiverId;
  final DateTime createdAt;
  final ConnectionUser? receiver; // Nullable for safety
  final ConnectionUser? sender;   // Nullable for safety

  PendingConnection({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.createdAt,
    this.receiver,
    this.sender,
  });

  factory PendingConnection.fromJson(Map<String, dynamic> json) => PendingConnection(
    // The .toString() and ?? "" prevent the Null subtype error
    id: json["id"]?.toString() ?? "",
    senderId: json["senderId"]?.toString() ?? "",
    receiverId: json["receiverId"]?.toString() ?? "",
    createdAt: json["createdAt"] == null
        ? DateTime.now()
        : DateTime.parse(json["createdAt"]),
    receiver: json["receiver"] == null ? null : ConnectionUser.fromJson(json["receiver"]),
    sender: json["sender"] == null ? null : ConnectionUser.fromJson(json["sender"]),
  );

  /// Returns the partner that is NOT the current user
  ConnectionUser? getDisplayPartner(String currentUserId) {
    return senderId == currentUserId ? receiver : sender;
  }
}

class ConnectionUser {
  final String id;
  final String? legalName;
  final String? businessName;
  final String fullName;
  final List<String> businessCategory;
  final int? operationYears;
  final String? businessImage;
  final String? profileImage;
  final String? position;
  final double? businessLatitude;
  final double? businessLongitude;

  ConnectionUser({
    required this.id,
    this.legalName,
    this.businessName,
    required this.fullName,
    required this.businessCategory,
    this.operationYears,
    this.businessImage,
    this.profileImage,
    this.position,
    this.businessLatitude,
    this.businessLongitude,
  });

  factory ConnectionUser.fromJson(Map<String, dynamic> json) => ConnectionUser(
    id: json["id"].toString(),
    legalName: json["legalName"]?.toString(),
    businessName: json["businessName"]?.toString(),
    fullName: json["fullName"]?.toString() ?? "Unknown User",
    businessCategory: json["businessCategory"] == null
        ? []
        : List<String>.from(json["businessCategory"].map((x) => x.toString())),
    operationYears: json["operationYears"] as int?,
    businessImage: json["businessImage"]?.toString(),
    profileImage: json["profileImage"]?.toString(),
    position: json["position"]?.toString(),
    // businessLatitude/Longitude can be int or double in JSON, so use as num?
    businessLatitude: (json["businessLatitude"] as num?)?.toDouble(),
    businessLongitude: (json["businessLongitude"] as num?)?.toDouble(),
  );
}

class ConnectionMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  ConnectionMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory ConnectionMeta.fromJson(Map<String, dynamic> json) => ConnectionMeta(
    page: json["page"] ?? 1,
    limit: json["limit"] ?? 10,
    total: json["total"] ?? 0,
    totalPages: json["totalPages"] ?? 1,
  );
}