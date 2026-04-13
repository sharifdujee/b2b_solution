enum ConnectionFilterOption { Connected, Pending, Find }


class MyConnectionStateModel {
  final String id;
  final String senderId;
  final String  receiverId;
  final String? status;
  final DateTime createdAt;
  final ConnectionUserData? receiver;
  final ConnectionUserData? sender;

  MyConnectionStateModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.status,
    required this.createdAt,
    this.receiver,
    this.sender,
  });

  factory MyConnectionStateModel.fromJson(Map<String, dynamic> json) {
    return MyConnectionStateModel(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      status: json['status']?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      receiver: json['receiver'] != null
          ? ConnectionUserData.fromJson(json['receiver'])
          : null,
      sender: json['sender'] != null
          ? ConnectionUserData.fromJson(json['sender'])
          : null,
    );
  }

  /// Helper method to get the "Other Person's" data
  /// Pass the current logged-in user's ID here
  ConnectionUserData? getDisplayUser(String currentUserId) {
    if (currentUserId == receiverId) {
      return sender;
    } else {
      return receiver;
    }
  }
}

class ConnectionUserData {
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

  ConnectionUserData({
    this.legalName,
    this.businessName,
    required this.fullName,
    this.businessCategory = const [],
    this.operationYears,
    this.businessImage,
    this.profileImage,
    this.position,
    this.businessLatitude,
    this.businessLongitude,
  });

  factory ConnectionUserData.fromJson(Map<String, dynamic> json) {
    return ConnectionUserData(
      legalName: json['legalName'],
      businessName: json['businessName'],
      fullName: json['fullName'] ?? 'Unknown User',
      businessCategory: json['businessCategory'] != null
          ? List<String>.from(json['businessCategory'])
          : [],
      operationYears: json['operationYears'],
      businessImage: json['businessImage'],
      profileImage: json['profileImage'],
      position: json['position'],
      businessLatitude: (json['businessLatitude'] as num?)?.toDouble(),
      businessLongitude: (json['businessLongitude'] as num?)?.toDouble(),
    );
  }
}