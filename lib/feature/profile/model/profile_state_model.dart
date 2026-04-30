// To parse this JSON data, do
//
//     final profileStateModel = profileStateModelFromJson(jsonString);

import 'dart:convert';

ProfileStateModel profileStateModelFromJson(String str) => ProfileStateModel.fromJson(json.decode(str));

String profileStateModelToJson(ProfileStateModel data) => json.encode(data.toJson());

class ProfileStateModel {
  bool success;
  String message;
  UserModel user;

  ProfileStateModel({
    required this.success,
    required this.message,
    required this.user,
  });

  factory ProfileStateModel.fromJson(Map<String, dynamic> json) => ProfileStateModel(
    success: json["success"],
    message: json["message"],
    user: UserModel.fromJson(json["result"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "result": user.toJson(),
  };
}

class UserModel {
  String id;
  String email;
  String fullName;
  String? businessName; // Optional
  String role;
  DateTime? lastLoginAt; // Optional
  String? legalName; // Optional
  double? latitude; // Optional
  double? longitude; // Optional
  List<String>? businessCategory; // Optional
  int? operationYears; // Optional
  String? position; // Optional
  String? profileImage; // Optional
  String? businessImage; // Optional
  String? loginType; // Optional
  DateTime? createdAt; // Optional
  double? businessLatitude;
  double? businessLongitude;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.latitude,
    this.longitude,
    this.businessName,
    required this.role,
    this.lastLoginAt,
    this.legalName,
    this.businessCategory,
    this.operationYears,
    this.position,
    this.profileImage,
    this.businessImage,
    this.loginType,
    this.createdAt,
    this.businessLatitude,
    this.businessLongitude,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"] ?? "",
    email: json["email"] ?? "",
    fullName: json["fullName"] ?? "",
    latitude: (json["businessLatitude"] as num?)?.toDouble(),
    longitude: (json["businessLongitude"] as num?)?.toDouble(),
    businessName: json["businessName"],
    role: json["role"] ?? "user",
    lastLoginAt: json["lastLoginAt"] == null ? null : DateTime.parse(json["lastLoginAt"]),
    legalName: json["legalName"],
    businessCategory: json["businessCategory"] == null
        ? []
        : List<String>.from(json["businessCategory"]),
    operationYears: json["operationYears"],
    position: json["position"],
    profileImage: json["profileImage"],
    businessImage: json["businessImage"],
    loginType: json["loginType"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    businessLatitude: (json["businessLatitude"] as num?)?.toDouble(),
    businessLongitude: (json["businessLongitude"] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "fullName": fullName,
    "role": role,
    "businessName": businessName,
    "lastLoginAt": lastLoginAt?.toIso8601String(),
    "legalName": legalName,
    "businessCategory": businessCategory != null
        ? List<dynamic>.from(businessCategory!.map((x) => x))
        : [],
    "operationYears": operationYears,
    "position": position,
    "profileImage": profileImage,
    "businessImage": businessImage,
    "loginType": loginType,
    "createdAt": createdAt?.toIso8601String(),
    "businessLatitude": businessLatitude,
    "businessLongitude": businessLongitude,
  };
}
