import 'dart:convert';

class NotificationResponseModel {
  final bool? success;
  final String? message;
  final NotificationResult? result;

  NotificationResponseModel({
    this.success,
    this.message,
    this.result,
  });

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) => NotificationResponseModel(
    success: json["success"],
    message: json["message"],
    result: json["result"] == null ? null : NotificationResult.fromJson(json["result"]),
  );
}

class NotificationResult {
  final Meta? meta;
  final List<NotificationData>? data;

  NotificationResult({
    this.meta,
    this.data,
  });

  factory NotificationResult.fromJson(Map<String, dynamic> json) => NotificationResult(
    meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
    data: json["data"] == null
        ? null
        : List<NotificationData>.from(json["data"].map((x) => NotificationData.fromJson(x))),
  );
}

class Meta {
  final int? page;
  final int? limit;
  final int? total;
  final int? totalPages;

  Meta({
    this.page,
    this.limit,
    this.total,
    this.totalPages,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    page: json["page"],
    limit: json["limit"],
    total: json["total"],
    totalPages: json["totalPages"],
  );
}

class NotificationData {
  final String? id;
  final String? title;
  final String? body;
  final bool? isRead;
  final String? type;
  final String? notificationChannel;
  final NotificationMetaData? metaData;
  final Sender? sender;
  final DateTime? createdAt;

  NotificationData({
    this.id,
    this.title,
    this.body,
    this.isRead,
    this.type,
    this.notificationChannel,
    this.metaData,
    this.sender,
    this.createdAt,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) => NotificationData(
    id: json["id"],
    title: json["title"],
    body: json["body"],
    isRead: json["isRead"],
    type: json["type"],
    notificationChannel: json["notificationChannel"],
    metaData: json["metaData"] == null ? null : NotificationMetaData.fromJson(json["metaData"]),
    sender: json["sender"] == null ? null : Sender.fromJson(json["sender"]),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
  );
}

class NotificationMetaData {
  final String? action;
  final String? actionId;
  final Extra? extra;
  final String? messagePreview;

  NotificationMetaData({
    this.action,
    this.actionId,
    this.extra,
    this.messagePreview,
  });

  factory NotificationMetaData.fromJson(Map<String, dynamic> json) => NotificationMetaData(
    action: json["action"],
    actionId: json["actionId"],
    extra: json["extra"] == null ? null : Extra.fromJson(json["extra"]),
    messagePreview: json["messagePreview"],
  );
}

class Extra {
  final String? deeplink;
  final String? priority;
  final String? sound;

  Extra({
    this.deeplink,
    this.priority,
    this.sound,
  });

  factory Extra.fromJson(Map<String, dynamic> json) => Extra(
    deeplink: json["deeplink"],
    priority: json["priority"],
    sound: json["sound"],
  );
}

class Sender {
  final String? id;
  final String? fullName;
  final String? profileImage;
  final String? legalName;

  Sender({
    this.id,
    this.fullName,
    this.profileImage,
    this.legalName,
  });

  factory Sender.fromJson(Map<String, dynamic> json) => Sender(
    id: json["id"],
    fullName: json["fullName"],
    profileImage: json["profileImage"],
    legalName: json["legalName"],
  );
}