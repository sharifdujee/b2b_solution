import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

enum FoodCategory {
  snacks,
  soups,
  drinks,
  salads,
  appetizers,
  mainCourse,
  desserts,
  bakery,
  dairy,
  frozenFood,
  meatPoultry
}

enum RadiusOption { km5, km10, km15, km20 }

extension FoodCategoryX on FoodCategory {
  String get label {
    switch (this) {
      case FoodCategory.snacks:       return 'Snacks';
      case FoodCategory.soups:        return 'Soups';
      case FoodCategory.drinks:       return 'Drinks';
      case FoodCategory.salads:       return 'Salads';
      case FoodCategory.appetizers:   return 'Appetizers';
      case FoodCategory.mainCourse:   return 'Main Course';
      case FoodCategory.desserts:     return 'Desserts';
      case FoodCategory.bakery:       return 'Bakery';
      case FoodCategory.dairy:        return 'Dairy';
      case FoodCategory.frozenFood:   return 'Frozen Food';
      case FoodCategory.meatPoultry:  return 'Meat & Poultry';
    }
  }

  static FoodCategory fromString(String category) {
    return FoodCategory.values.firstWhere(
          (e) => e.name == category.toLowerCase(),
      orElse: () => FoodCategory.snacks,
    );
  }
}

extension RadiusOptionX on RadiusOption {
  String get label {
    switch (this) {
      case RadiusOption.km5:  return '5 km';
      case RadiusOption.km10: return '10 km';
      case RadiusOption.km15: return '15 km';
      case RadiusOption.km20: return '20 km';
    }
  }

  int get value {
    switch (this) {
      case RadiusOption.km5:  return 5;
      case RadiusOption.km10: return 10;
      case RadiusOption.km15: return 15;
      case RadiusOption.km20: return 20;
    }
  }
}

class PlaceLocation {
  final String id;
  final String name;
  final String address;
  final LatLng position;
  final FoodCategory category;

  const PlaceLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.position,
    required this.category,
  });


  factory PlaceLocation.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] as Map<String, dynamic>?;

    final random = Random();
    double jitter() => (random.nextDouble() - 0.5) * 0.0001;

    return PlaceLocation(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['itemName'] ?? 'Unknown Item',
      address: userMap?['businessName'] ?? '',
      category: FoodCategoryX.fromString(json['category'] ?? ''),
      position: LatLng(
        (userMap?['businessLatitude'] ?? 0.0).toDouble() + jitter(),
        (userMap?['businessLongitude'] ?? 0.0).toDouble() + jitter(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'category': category.name,
      'lat': position.latitude,
      'lng': position.longitude,
    };
  }
}

class SearchSuggestion {
  final String placeId;
  final String mainText;
  final String secondaryText;

  const SearchSuggestion({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
  });
}