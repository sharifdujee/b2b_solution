

// To parse this JSON data, do
//
//     final roomMessageDataModel = roomMessageDataModelFromJson(jsonString);

import 'dart:convert';

RoomMessageDataModel roomMessageDataModelFromJson(String str) => RoomMessageDataModel.fromJson(json.decode(str));

String roomMessageDataModelToJson(RoomMessageDataModel data) => json.encode(data.toJson());

class RoomMessageDataModel {
  bool success;
  String message;
  RoomMessageResult result;

  RoomMessageDataModel({
    required this.success,
    required this.message,
    required this.result,
  });

  factory RoomMessageDataModel.fromJson(Map<String, dynamic> json) => RoomMessageDataModel(
    success: json["success"],
    message: json["message"],
    result: RoomMessageResult.fromJson(json["result"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "result": result.toJson(),
  };
}

class RoomMessageResult {
  MessageMeta meta;
  List<MessageData> data;

  RoomMessageResult({
    required this.meta,
    required this.data,
  });

  factory RoomMessageResult.fromJson(Map<String, dynamic> json) => RoomMessageResult(
    meta: MessageMeta.fromJson(json["meta"]),
    data: List<MessageData>.from(json["data"].map((x) => MessageData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "meta": meta.toJson(),
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class MessageData {
  String id;
  String content;
  List<dynamic> fileUrl;
  String senderId;
  String roomId;
  String messageType;
  DateTime createdAt;
  DateTime updatedAt;
  Sender sender;

  MessageData({
    required this.id,
    required this.content,
    required this.fileUrl,
    required this.senderId,
    required this.roomId,
    required this.messageType,
    required this.createdAt,
    required this.updatedAt,
    required this.sender,
  });

  factory MessageData.fromJson(Map<String, dynamic> json) => MessageData(
    id: json["id"],
    content: json["content"],
    fileUrl: List<dynamic>.from(json["fileUrl"].map((x) => x)),
    senderId: json["senderId"],
    roomId: json["roomId"],
    messageType: json["messageType"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    sender: Sender.fromJson(json["sender"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "content": content,
    "fileUrl": List<dynamic>.from(fileUrl.map((x) => x)),
    "senderId": senderId,
    "roomId": roomId,
    "messageType": messageType,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "sender": sender.toJson(),
  };
}

class Sender {
  String id;
  String fullName;
  String? businessName;
  String? profileImage;

  Sender({
    required this.id,
    required this.fullName,
    required this.businessName,
    required this.profileImage,
  });

  factory Sender.fromJson(Map<String, dynamic> json) => Sender(
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

class MessageMeta {
  int page;
  int limit;
  int total;
  int totalPages;

  MessageMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory MessageMeta.fromJson(Map<String, dynamic> json) => MessageMeta(
    page: json["page"],
    limit: json["limit"],
    total: json["total"],
    totalPages: json["totalPages"],
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "limit": limit,
    "total": total,
    "totalPages": totalPages,
  };
}
