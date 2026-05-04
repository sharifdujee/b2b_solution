import 'dart:convert';

ConversationDataModel conversationDataModelFromJson(String str) =>
    ConversationDataModel.fromJson(json.decode(str));

String conversationDataModelToJson(ConversationDataModel data) =>
    json.encode(data.toJson());

class ConversationDataModel {
  final bool success;
  final String message;
  final List<ConversationResult> result;

  ConversationDataModel({
    required this.success,
    required this.message,
    required this.result,
  });

  factory ConversationDataModel.fromJson(Map<String, dynamic> json) => ConversationDataModel(
    success: json["success"] ?? false,
    message: json["message"] ?? "",
    result: json["result"] == null
        ? []
        : List<ConversationResult>.from(json["result"].map((x) => ConversationResult.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "result": List<dynamic>.from(result.map((x) => x.toJson())),
  };
}

class ConversationResult {
  final String roomId;
  final String roomType;
  final Partner partner;
  final LastMessage? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  ConversationResult({
    required this.roomId,
    required this.roomType,
    required this.partner,
    this.lastMessage,
    required this.unreadCount,
    required this.updatedAt,
  });

  factory ConversationResult.fromJson(Map<String, dynamic> json) => ConversationResult(
    roomId: json["roomId"] ?? "",
    roomType: json["roomType"] ?? "",
    partner: Partner.fromJson(json["partner"] ?? {}),
    // Null-safe check for lastMessage
    lastMessage: (json["lastMessage"] != null && json["lastMessage"] is Map)
        ? LastMessage.fromJson(json["lastMessage"])
        : null,
    unreadCount: json["unreadCount"] ?? 0,
    // Defensive date parsing
    updatedAt: DateTime.tryParse(json["updatedAt"] ?? "") ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    "roomId": roomId,
    "roomType": roomType,
    "partner": partner.toJson(),
    "lastMessage": lastMessage?.toJson(),
    "unreadCount": unreadCount,
    "updatedAt": updatedAt.toIso8601String(),
  };
}

class LastMessage {
  final String content;
  final DateTime createdAt;
  final String type;
  final String senderId;

  LastMessage({
    required this.content,
    required this.createdAt,
    required this.type,
    required this.senderId,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) => LastMessage(
    content: json["content"] ?? "",
    createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
    type: json["type"] ?? "TEXT",
    senderId: json["senderId"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "content": content,
    "createdAt": createdAt.toIso8601String(),
    "type": type,
    "senderId": senderId,
  };
}

class Partner {
  final String id;
  final String fullName;
  final String? businessName; // Changed dynamic to String? for safety
  final String? profileImage; // Changed dynamic to String? for safety

  Partner({
    required this.id,
    required this.fullName,
    this.businessName,
    this.profileImage,
  });

  factory Partner.fromJson(Map<String, dynamic> json) => Partner(
    id: json["id"] ?? "",
    fullName: json["fullName"] ?? "Unknown",
    businessName: json["businessName"]?.toString(),
    profileImage: json["profileImage"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "fullName": fullName,
    "businessName": businessName,
    "profileImage": profileImage,
  };
}