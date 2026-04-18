class Message {
  final String? id;
  final String? roomId;
  final String? senderId;
  final String? text;
  final bool isRead;
  final DateTime? createdAt;

  Message({
    this.id,
    this.roomId,
    this.senderId,
    this.text,
    this.isRead = false,
    this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json["id"],
    roomId: json["roomId"],
    senderId: json["senderId"],
    text: json["text"] ?? json["message"],
    isRead: json["isRead"] ?? false,
    createdAt: json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
  );

  Message copyWith({bool? isRead, String? text}) => Message(
    id: id,
    roomId: roomId,
    senderId: senderId,
    text: text ?? this.text,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
  );
}