class ConnectedConnectionModel {
  final bool success;
  final String message;
  final ConnectedResult? result;

  ConnectedConnectionModel({
    required this.success,
    required this.message,
    this.result,
  });

  factory ConnectedConnectionModel.fromJson(Map<String, dynamic> json) => ConnectedConnectionModel(
    success: json["success"] ?? false,
    message: json["message"] ?? "",
    result: json["result"] == null ? null : ConnectedResult.fromJson(json["result"]),
  );
}

class ConnectedResult {
  final List<ConnectedConnection> data;
  final ConnectionMeta? meta;

  ConnectedResult({
    required this.data,
    this.meta,
  });

  factory ConnectedResult.fromJson(Map<String, dynamic> json) => ConnectedResult(
    data: json["data"] == null
        ? []
        : List<ConnectedConnection>.from(json["data"].map((x) => ConnectedConnection.fromJson(x))),
    meta: json["meta"] == null ? null : ConnectionMeta.fromJson(json["meta"]),
  );
}

class ConnectedConnection {
  final String id;
  final String senderId;
  final String receiverId;
  final DateTime? createdAt;
  final ConnectionUser? receiver;
  final ConnectionUser? sender;

  ConnectedConnection({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.createdAt,
    this.receiver,
    this.sender,
  });

  factory ConnectedConnection.fromJson(Map<String, dynamic> json) => ConnectedConnection(
    id: json["id"]?.toString() ?? "",
    senderId: json["senderId"]?.toString() ?? "",
    receiverId: json["receiverId"]?.toString() ?? "",
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    receiver: json["receiver"] == null ? null : ConnectionUser.fromJson(json["receiver"]),
    sender: json["sender"] == null ? null : ConnectionUser.fromJson(json["sender"]),
  );

  ConnectionUser? getDisplayPartner(String currentUserId) {
    return senderId == currentUserId ? receiver : sender;
  }

  String getPartnerId(String currentUserId) {
    return senderId == currentUserId ? receiverId : senderId;
  }
}

class ConnectionUser {
  final String? legalName;
  final String? businessName;
  final String fullName;
  final String? email; // Added email field
  final List<String> businessCategory;
  final int? operationYears;
  final String? businessImage;
  final String? profileImage;
  final String? position;
  final double? businessLatitude;
  final double? businessLongitude;

  ConnectionUser({
    this.legalName,
    this.businessName,
    required this.fullName,
    this.email, // Added to constructor
    required this.businessCategory,
    this.operationYears,
    this.businessImage,
    this.profileImage,
    this.position,
    this.businessLatitude,
    this.businessLongitude,
  });

  factory ConnectionUser.fromJson(Map<String, dynamic> json) => ConnectionUser(
    legalName: json["legalName"]?.toString(),
    businessName: json["businessName"]?.toString(),
    fullName: json["fullName"]?.toString() ?? "Unknown User",
    email: json["email"]?.toString(), // Mapped from JSON
    businessCategory: json["businessCategory"] == null
        ? []
        : List<String>.from(json["businessCategory"].map((x) => x.toString())),
    operationYears: json["operationYears"] as int?,
    businessImage: json["businessImage"]?.toString(),
    profileImage: json["profileImage"]?.toString(),
    position: json["position"]?.toString(),
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
    limit: json["limit"] ?? 20,
    total: json["total"] ?? 0,
    totalPages: json["totalPages"] ?? 1,
  );
}