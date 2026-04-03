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

class UserModel{
  String id;
  String email;
  String fullName;
  //String businessName;
  String role;
  DateTime lastLoginAt;
  String legalName;
  List<String> businessCategory;
  int operationYears;
  String position;
  String profileImage;
  String businessImage;
  String loginType;
  DateTime createdAt;
  double? businessLatitude;
  double? businessLongitude;


  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    //required this.businessName,
    required this.role,
    required this.lastLoginAt,
    required this.legalName,
    required this.businessCategory,
    required this.operationYears,
    required this.position,
    required this.profileImage,
    required this.businessImage,
    required this.loginType,
    required this.createdAt,
    this.businessLatitude,
    this.businessLongitude,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"],
    email: json["email"],
    fullName: json["fullName"],
    //businessName: json["businessName"],
    role: json["role"],
    lastLoginAt: DateTime.parse(json["lastLoginAt"]),
    legalName: json["legalName"],
    businessCategory: List<String>.from(json["businessCategory"] ?? []),
    operationYears: json["operationYears"],
    position: json["position"],
    profileImage: json["profileImage"],
    businessImage: json["businessImage"],
    loginType: json["loginType"],
    createdAt: DateTime.parse(json["createdAt"]),
    businessLatitude: json["businessLatitude"],
    businessLongitude: json["businessLongitude"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "fullName": fullName,
    "role": role,
    //"businessName": businessName,
    "lastLoginAt": lastLoginAt.toIso8601String(),
    "legalName": legalName,
    "businessCategory": List<dynamic>.from(businessCategory.map((x) => x)),
    "operationYears": operationYears,
    "position": position,
    "profileImage": profileImage,
    "businessImage": businessImage,
    "loginType": loginType,
    "createdAt": createdAt.toIso8601String(),
    "businessLatitude": businessLatitude,
    "businessLongitude": businessLongitude,
  };
}
