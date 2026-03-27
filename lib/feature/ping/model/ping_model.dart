import '../provider/ping_provider.dart';

enum PingPriority { emergency, moderate, general }

class PingModel {
  final String shopName;
  final String needs;
  final String distance;
  final String logoUrl;
  final PingPriority priority;
  final PingFilter category;
  final String? productCategory;
  final int? membershipYear;
  final String? shopAddress;
  final String? itemName;
  final double? quanity;
  final String? unit;
  final String? neededWithin;
  final String? notes;
  final int? radius;
  final List<String>? chooseConnection;
  final bool myConnectionOnly;

  PingModel({
    required this.shopName,
    required this.needs,
    required this.distance,
    required this.logoUrl,
    required this.priority,
    required this.category,
    this.productCategory, // Initialize here
    this.membershipYear = 0,
    this.shopAddress,
    this.itemName,
    this.quanity,
    this.unit,
    this.neededWithin,
    this.notes,
    this.radius,
    this.chooseConnection,
    this.myConnectionOnly = false
  });

  PingModel copyWith({
    String? shopName,
    String? needs,
    String? distance,
    String? logoUrl,
    PingPriority? priority,
    PingFilter? category,
    String? productCategory, // Add to copyWith
    int? membershipYear,
    String? shopAddress,
    String? itemName,
    double? quanity,
    String? unit,
    String? neededWithin,
    String? notes,
    int? radius,
    List<String>? chooseConnection,
    bool? myConnectionOnly,
  }) {
    return PingModel(
      shopName: shopName ?? this.shopName,
      needs: needs ?? this.needs,
      distance: distance ?? this.distance,
      logoUrl: logoUrl ?? this.logoUrl,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      productCategory: productCategory ?? this.productCategory, // Map it here
      membershipYear: membershipYear ?? this.membershipYear,
      shopAddress: shopAddress ?? this.shopAddress,
      itemName: itemName ?? this.itemName,
      quanity: quanity ?? this.quanity,
      unit: unit ?? this.unit,
      neededWithin: neededWithin ?? this.neededWithin,
      notes: notes ?? this.notes,
      radius: radius ?? this.radius,
      chooseConnection: chooseConnection ?? this.chooseConnection,
      myConnectionOnly: myConnectionOnly ?? this.myConnectionOnly,
    );
  }
}