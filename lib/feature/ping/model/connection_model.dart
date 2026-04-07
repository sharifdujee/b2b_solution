class ConnectionModel {
  final String id;
  final String senderId;
  final String receiverId;
  final ConnectionUser? sender;
  final ConnectionUser? receiver;

  ConnectionModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.sender,
    this.receiver,
  });

  factory ConnectionModel.fromJson(Map<String, dynamic> json) {
    return ConnectionModel(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      sender: json['sender'] != null ? ConnectionUser.fromJson(json['sender']) : null,
      receiver: json['receiver'] != null ? ConnectionUser.fromJson(json['receiver']) : null,
    );
  }

  ConnectionUser? getDisplayUser(String currentUserId) {
    return senderId == currentUserId ? receiver : sender;
  }
}

class ConnectionUser {
  final String fullName;
  final String? businessName;
  final String? profileImage;
  final List<String> businessCategory;

  ConnectionUser({
    required this.fullName,
    this.businessName,
    this.profileImage,
    required this.businessCategory,
  });

  factory ConnectionUser.fromJson(Map<String, dynamic> json) {
    return ConnectionUser(
      fullName: json['fullName'] ?? '',
      businessName: json['businessName'],
      profileImage: json['profileImage'],
      businessCategory: List<String>.from(json['businessCategory'] ?? []),
    );
  }
}