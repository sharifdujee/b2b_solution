


import 'package:google_maps_flutter/google_maps_flutter.dart';

class PingRequest {
  final String id;
  final String title;
  final String description;
  final String vendorName;
  final String vendorAvatar; // asset path
  final LatLng location;
  final double distanceKm;
  final DateTime postedAt;
  final PingStatus status;
  final String category; // e.g. "Coffee", "Retail", "Food"

  const PingRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.vendorName,
    required this.vendorAvatar,
    required this.location,
    required this.distanceKm,
    required this.postedAt,
    required this.status,
    required this.category,
  });

  PingRequest copyWith({PingStatus? status}) => PingRequest(
    id: id,
    title: title,
    description: description,
    vendorName: vendorName,
    vendorAvatar: vendorAvatar,
    location: location,
    distanceKm: distanceKm,
    postedAt: postedAt,
    status: status ?? this.status,
    category: category,
  );
}

enum PingStatus { pending, accepted, declined }