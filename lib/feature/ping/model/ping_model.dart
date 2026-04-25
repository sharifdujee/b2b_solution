import 'dart:convert';

PingModel pingModelFromJson(String str) =>
    PingModel.fromJson(json.decode(str));

String pingModelToJson(PingModel data) =>
    json.encode(data.toJson());

class PingModel {
  final bool success;
  final String message;
  final Result? result;

  PingModel({
    required this.success,
    required this.message,
    this.result,
  });

  factory PingModel.fromJson(Map<String, dynamic> json) => PingModel(
    success: json["success"] ?? false,
    message: json["message"] ?? "",
    result: json["result"] == null
        ? null
        : Result.fromJson(json["result"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "result": result?.toJson(),
  };
}

class Result {
  final Meta? meta;
  final List<Datum> data;

  Result({
    this.meta,
    required this.data,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    meta: json["meta"] == null
        ? null
        : Meta.fromJson(json["meta"]),
    data: json["data"] == null
        ? []
        : List<Datum>.from(
      json["data"].map((x) => Datum.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "meta": meta?.toJson(),
    "data": List<dynamic>.from(
      data.map((x) => x.toJson()),
    ),
  };
}

class Datum {
  final String id;
  final String userId;
  final String itemName;
  final int quantity;
  final String unit;
  final String urgencyLevel;
  final int neededWithin;
  final User? user;
  final double distanceKm;

  Datum({
    required this.id,
    required this.userId,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.urgencyLevel,
    required this.neededWithin,
    this.user,
    required this.distanceKm,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"]?.toString() ?? "",
    userId: json["userId"]?.toString() ?? "",
    itemName: json["itemName"] ?? "Unknown Item",
    quantity: (json["quantity"] as num?)?.toInt() ?? 0,
    unit: json["unit"] ?? "",
    urgencyLevel: json["urgencyLevel"] ?? "GENERAL",
    neededWithin:
    (json["neededWithin"] as num?)?.toInt() ?? 0,
    user: json["user"] == null
        ? null
        : User.fromJson(json["user"]),
    distanceKm:
    (json["distanceKm"] as num?)?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "itemName": itemName,
    "quantity": quantity,
    "unit": unit,
    "urgencyLevel": urgencyLevel,
    "neededWithin": neededWithin,
    "user": user?.toJson(),
    "distanceKm": distanceKm,
  };
}

class User {
  final String legalName;
  final String businessName;
  final String fullName;
  final String profileImage;
  final double businessLatitude;
  final double businessLongitude;

  User({
    required this.legalName,
    required this.businessName,
    required this.fullName,
    required this.profileImage,
    required this.businessLatitude,
    required this.businessLongitude,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    legalName: json["legalName"] ?? "",
    businessName:
    json["businessName"] ?? "Unknown Shop",
    fullName: json["fullName"] ?? "",
    profileImage: json["profileImage"] ?? "",
    businessLatitude:
    (json["businessLatitude"] as num?)
        ?.toDouble() ??
        0.0,
    businessLongitude:
    (json["businessLongitude"] as num?)
        ?.toDouble() ??
        0.0,
  );

  Map<String, dynamic> toJson() => {
    "legalName": legalName,
    "businessName": businessName,
    "fullName": fullName,
    "profileImage": profileImage,
    "businessLatitude": businessLatitude,
    "businessLongitude": businessLongitude,
  };
}

class Meta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  Meta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    page: (json["page"] as num?)?.toInt() ?? 1,
    limit: (json["limit"] as num?)?.toInt() ?? 10,
    total: (json["total"] as num?)?.toInt() ?? 0,
    totalPages:
    (json["totalPages"] as num?)?.toInt() ?? 1,
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "limit": limit,
    "total": total,
    "totalPages": totalPages,
  };
}