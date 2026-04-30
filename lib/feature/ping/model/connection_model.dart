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
    // Logic to handle "Find User" API response (Direct User Object)
    if (json.containsKey('fullName') && !json.containsKey('sender')) {
      final user = ConnectionUser.fromJson(json);
      return ConnectionModel(
        id: json['id'] ?? '',
        senderId: "", // Marker to indicate this is a direct user result
        receiverId: json['id'] ?? '',
        receiver: user,
      );
    }

    // Logic to handle "Connected Search" API response (Connection Wrapper)
    return ConnectionModel(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      sender: json['sender'] != null ? ConnectionUser.fromJson(json['sender']) : null,
      receiver: json['receiver'] != null ? ConnectionUser.fromJson(json['receiver']) : null,
    );
  }

  ConnectionUser? getDisplayUser(String currentUserId) {
    // If senderId is empty, it's from the Find/Discover API
    if (senderId.isEmpty) return receiver;
    // Otherwise, find the partner in the connection
    return senderId == currentUserId ? receiver : sender;
  }
}

class ConnectionUser {
  final String fullName;
  final String? businessName;
  final String? profileImage;
  final List<String> businessCategory;
  final double? businessLatitude;
  final double? businessLongitude;
  final String? position;

  ConnectionUser({
    required this.fullName,
    this.businessName,
    this.profileImage,
    required this.businessCategory,
    this.businessLatitude,
    this.businessLongitude,
    this.position,
  });

  factory ConnectionUser.fromJson(Map<String, dynamic> json) {
    return ConnectionUser(
      fullName: json['fullName'] ?? '',
      businessName: json['businessName'],
      profileImage: json['profileImage'],
      position: json['position'],
        businessLatitude: json['businessLatitude'],
      businessLongitude: json['businessLongitude'],
      businessCategory: List<String>.from(json['businessCategory'] ?? []),
    );
  }
}