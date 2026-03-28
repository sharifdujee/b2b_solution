


import 'package:google_maps_flutter/google_maps_flutter.dart';

enum FoodCategory { snacks, soups, drinks, salads }

enum RadiusOption { km5, km10, km15, km20 }

extension FoodCategoryX on FoodCategory {
  String get label {
    switch (this) {
      case FoodCategory.snacks:  return 'Snacks';
      case FoodCategory.soups:   return 'Soups';
      case FoodCategory.drinks:  return 'Drinks';
      case FoodCategory.salads:  return 'Salads';
    }
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

  double get km {
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
