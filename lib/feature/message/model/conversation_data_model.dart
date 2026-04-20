
import 'dart:convert';

ConversationDataModel conversationDataModelFromJson(String str) => ConversationDataModel.fromJson(json.decode(str));

String conversationDataModelToJson(ConversationDataModel data) => json.encode(data.toJson());

class ConversationDataModel {
  bool success;
  String message;
  List<ConversationResult> result;

  ConversationDataModel({
    required this.success,
    required this.message,
    required this.result,
  });

  factory ConversationDataModel.fromJson(Map<String, dynamic> json) => ConversationDataModel(
    success: json["success"],
    message: json["message"],
    result: List<ConversationResult>.from(json["result"].map((x) => ConversationResult.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "result": List<dynamic>.from(result.map((x) => x.toJson())),
  };
}

class ConversationResult {
  String roomId;
  String roomType;
  Partner partner;
  LastMessage? lastMessage; // ← nullable
  int unreadCount;
  DateTime updatedAt;

  ConversationResult({
    required this.roomId,
    required this.roomType,
    required this.partner,
    this.lastMessage, // ← optional
    required this.unreadCount,
    required this.updatedAt,
  });

  factory ConversationResult.fromJson(Map<String, dynamic> json) => ConversationResult(
    roomId: json["roomId"],
    roomType: json["roomType"],
    partner: Partner.fromJson(json["partner"]),
    lastMessage: json["lastMessage"] != null
        ? LastMessage.fromJson(json["lastMessage"])
        : null, // ← null-safe parse
    unreadCount: json["unreadCount"],
    updatedAt: DateTime.parse(json["updatedAt"]),
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
  String content;
  DateTime createdAt;
  String type;
  String senderId;

  LastMessage({
    required this.content,
    required this.createdAt,
    required this.type,
    required this.senderId,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) => LastMessage(
    content: json["content"],
    createdAt: DateTime.parse(json["createdAt"]),
    type: json["type"],
    senderId: json["senderId"],
  );

  Map<String, dynamic> toJson() => {
    "content": content,
    "createdAt": createdAt.toIso8601String(),
    "type": type,
    "senderId": senderId,
  };
}

class Partner {
  String id;
  String fullName;
  dynamic businessName;
  dynamic profileImage;

  Partner({
    required this.id,
    required this.fullName,
    required this.businessName,
    required this.profileImage,
  });

  factory Partner.fromJson(Map<String, dynamic> json) => Partner(
    id: json["id"],
    fullName: json["fullName"],
    businessName: json["businessName"],
    profileImage: json["profileImage"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "fullName": fullName,
    "businessName": businessName,
    "profileImage": profileImage,
  };
}
