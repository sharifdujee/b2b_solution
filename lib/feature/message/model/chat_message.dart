class ChatMessage {
  final String id;
  final String content;
  final List<dynamic> fileUrl;
  final String senderId;
  final String roomId;
  final String messageType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Sender sender;

  // Local UI-only helper field
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.content,
    required this.fileUrl,
    required this.senderId,
    required this.roomId,
    required this.messageType,
    required this.createdAt,
    required this.updatedAt,
    required this.sender,
    this.isMe = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, {String? currentUserId}) => ChatMessage(
    id: json["id"],
    content: json["content"],
    fileUrl: List<dynamic>.from(json["fileUrl"].map((x) => x)),
    senderId: json["senderId"],
    roomId: json["roomId"],
    messageType: json["messageType"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    sender: Sender.fromJson(json["sender"]),
    // Logic to determine if the message was sent by the current user
    isMe: json["senderId"] == currentUserId,
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

  ChatMessage copyWith({
    String? content,
    bool? isMe,
  }) => ChatMessage(
    id: id,
    content: content ?? this.content,
    fileUrl: fileUrl,
    senderId: senderId,
    roomId: roomId,
    messageType: messageType,
    createdAt: createdAt,
    updatedAt: updatedAt,
    sender: sender,
    isMe: isMe ?? this.isMe,
  );
}

class Sender {
  final String id;
  final String fullName;
  final String? businessName;
  final String? profileImage;

  Sender({
    required this.id,
    required this.fullName,
    this.businessName,
    this.profileImage,
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