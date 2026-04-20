
import 'dart:convert';

FindConnectionStateModel findConnectionStateModelFromJson(String str) => FindConnectionStateModel.fromJson(json.decode(str));

String findConnectionStateModelToJson(FindConnectionStateModel data) => json.encode(data.toJson());

class FindConnectionStateModel {
  bool success;
  String message;
  FindResult findResult;

  FindConnectionStateModel({
    required this.success,
    required this.message,
    required this.findResult,
  });

  factory FindConnectionStateModel.fromJson(Map<String, dynamic> json) => FindConnectionStateModel(
    success: json["success"],
    message: json["message"],
    findResult: FindResult.fromJson(json["result"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "result": findResult.toJson(),
  };
}

class FindResult {
  FindMeta meta;
  List<FindDatum> data;

  FindResult({
    required this.meta,
    required this.data,
  });

  factory FindResult.fromJson(Map<String, dynamic> json) => FindResult(
    meta: FindMeta.fromJson(json["meta"]),
    data: List<FindDatum>.from(json["data"].map((x) => FindDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "meta": meta.toJson(),
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class FindDatum {
  String id;
  String legalName;
  String email;
  String businessName;
  String fullName;
  String profileImage;
  String businessImage;
  List<String> businessCategory;
  int operationYears;
  String position;
  double businessLatitude;
  double businessLongitude;

  FindDatum({
    required this.id,
    required this.legalName,
    required this.email,
    required this.businessName,
    required this.fullName,
    required this.profileImage,
    required this.businessImage,
    required this.businessCategory,
    required this.operationYears,
    required this.position,
    required this.businessLatitude,
    required this.businessLongitude,
  });

  factory FindDatum.fromJson(Map<String, dynamic> json) => FindDatum(
    id: json["id"] ?? '',
    legalName: json["legalName"] ?? '',
    email: json["email"] ?? '',
    businessName: json["businessName"] ?? '',
    fullName: json["fullName"] ?? '',
    profileImage: json["profileImage"] ?? '',
    businessImage: json["businessImage"] ?? '',
    businessCategory: json["businessCategory"] == null
        ? []
        : List<String>.from(json["businessCategory"].map((x) => x.toString())),
    operationYears: json["operationYears"] ?? 0,
    position: json["position"] ?? 'Business Professional',
    businessLatitude: (json["businessLatitude"] as num?)?.toDouble() ?? 0.0,
    businessLongitude: (json["businessLongitude"] as num?)?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "legalName": legalName,
    "businessName": businessName,
    "fullName": fullName,
    "profileImage": profileImage,
    "businessImage": businessImage,
    "businessCategory": List<dynamic>.from(businessCategory.map((x) => x)),
    "operationYears": operationYears,
    "position": position,
    "businessLatitude": businessLatitude,
    "businessLongitude": businessLongitude,
  };
}

class FindMeta {
  int page;
  int limit;
  int total;
  int totalPages;

  FindMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory FindMeta.fromJson(Map<String, dynamic> json) => FindMeta(
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
