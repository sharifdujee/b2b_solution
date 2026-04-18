import 'dart:convert';

SendRequestStateModel sendRequestStateModelFromJson(String str) => SendRequestStateModel.fromJson(json.decode(str));

String sendRequestStateModelToJson(SendRequestStateModel data) => json.encode(data.toJson());

class SendRequestStateModel {
  bool success;
  String message;
  SendRequestResult result;

  SendRequestStateModel({
    required this.success,
    required this.message,
    required this.result,
  });

  factory SendRequestStateModel.fromJson(Map<String, dynamic> json) => SendRequestStateModel(
    success: json["success"],
    message: json["message"],
    result: SendRequestResult.fromJson(json["result"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "result": result.toJson(),
  };
}

class SendRequestResult {
  Meta meta;
  List<SendRequestResultDatum> data;

  SendRequestResult({
    required this.meta,
    required this.data,
  });

  factory SendRequestResult.fromJson(Map<String, dynamic> json) => SendRequestResult(
    meta: Meta.fromJson(json["meta"]),
    data: List<SendRequestResultDatum>.from(json["data"].map((x) => SendRequestResultDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "meta": meta.toJson(),
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class SendRequestResultDatum {
  String id;
  String status;
  Receiver receiver;

  SendRequestResultDatum({
    required this.id,
    required this.status,
    required this.receiver,
  });

  factory SendRequestResultDatum.fromJson(Map<String, dynamic> json) => SendRequestResultDatum(
    id: json["id"],
    status: json["status"],
    receiver: Receiver.fromJson(json["receiver"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "receiver": receiver.toJson(),
  };
}

class Receiver {
  String id;
  String fullName;
  String email;
  String? legalName; // Changed to nullable
  String businessName;
  List<String> businessCategory;
  String? profileImage; // Changed to nullable
  String? businessImage; // Changed to nullable
  int? operationYears; // Changed to nullable
  String? position; // Changed to nullable
  double businessLatitude;
  double businessLongitude;

  Receiver({
    required this.id,
    required this.fullName,
    required this.email,
    this.legalName,
    required this.businessName,
    required this.businessCategory,
    this.profileImage,
    this.businessImage,
    this.operationYears,
    this.position,
    required this.businessLatitude,
    required this.businessLongitude,
  });

  factory Receiver.fromJson(Map<String, dynamic> json) => Receiver(
    id: json["id"] ?? "",
    fullName: json["fullName"] ?? "Unknown",
    email: json["email"] ?? "",
    legalName: json["legalName"],
    businessName: json["businessName"] ?? "Unknown Business",
    // Added a null check for businessCategory list
    businessCategory: json["businessCategory"] == null
        ? []
        : List<String>.from(json["businessCategory"].map((x) => x)),
    profileImage: json["profileImage"],
    businessImage: json["businessImage"],
    operationYears: json["operationYears"],
    position: json["position"],
    businessLatitude: (json["businessLatitude"] ?? 0.0).toDouble(),
    businessLongitude: (json["businessLongitude"] ?? 0.0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "fullName": fullName,
    "email": email,
    "legalName": legalName,
    "businessName": businessName,
    "businessCategory": List<dynamic>.from(businessCategory.map((x) => x)),
    "profileImage": profileImage,
    "businessImage": businessImage,
    "operationYears": operationYears,
    "position": position,
    "businessLatitude": businessLatitude,
    "businessLongitude": businessLongitude,
  };
}

class Meta {
  int page;
  int limit;
  int total;
  int totalPages;

  Meta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
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
