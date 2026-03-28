


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/place_location.dart';

class FilterState {
  final FoodCategory selectedCategory;
  final RadiusOption selectedRadius;

  const FilterState({
    this.selectedCategory = FoodCategory.snacks,
    this.selectedRadius   = RadiusOption.km5,
  });

  FilterState copyWith({
    FoodCategory? selectedCategory,
    RadiusOption? selectedRadius,
  }) =>
      FilterState(
        selectedCategory: selectedCategory ?? this.selectedCategory,
        selectedRadius:   selectedRadius   ?? this.selectedRadius,
      );
}

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState());

  void setCategory(FoodCategory category) =>
      state = state.copyWith(selectedCategory: category);

  void setRadius(RadiusOption radius) =>
      state = state.copyWith(selectedRadius: radius);
}

// ─────────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────────

final filterProvider =
StateNotifierProvider<FilterNotifier, FilterState>((ref) => FilterNotifier());

// Pending (not-yet-applied) filter – mirrors live filter until user hits Apply
final pendingFilterProvider =
StateNotifierProvider<FilterNotifier, FilterState>((ref) => FilterNotifier());

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchSuggestionsProvider =
Provider<List<SearchSuggestion>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  if (query.length < 2) return [];

  // Simulated suggestions – replace with Google Places Autocomplete in production
  final all = [
    SearchSuggestion(
        placeId: '1',
        mainText: 'Bashundhara City',
        secondaryText: 'Dhaka, Bangladesh'),
    SearchSuggestion(
        placeId: '2',
        mainText: 'Gulshan 1 Circle',
        secondaryText: 'Dhaka, Bangladesh'),
    SearchSuggestion(
        placeId: '3',
        mainText: 'Dhanmondi 27',
        secondaryText: 'Dhaka, Bangladesh'),
    SearchSuggestion(
        placeId: '4',
        mainText: 'Banani Block C',
        secondaryText: 'Dhaka, Bangladesh'),
    SearchSuggestion(
        placeId: '5',
        mainText: 'Uttara Sector 7',
        secondaryText: 'Dhaka, Bangladesh'),
    SearchSuggestion(
        placeId: '6',
        mainText: 'Motijheel C/A',
        secondaryText: 'Dhaka, Bangladesh'),
  ];

  return all
      .where((s) =>
  s.mainText.toLowerCase().contains(query) ||
      s.secondaryText.toLowerCase().contains(query))
      .toList();
});

// Nearby places (simulated)
final nearbyPlacesProvider = Provider<List<PlaceLocation>>((ref) {
  final filter = ref.watch(filterProvider);

  final allPlaces = [
    PlaceLocation(
        id: 'p1',
        name: 'Crispy Corner',
        address: 'Gulshan 2, Dhaka',
        position: const LatLng(23.793, 90.414),
        category: FoodCategory.snacks),
    PlaceLocation(
        id: 'p2',
        name: 'Soup House',
        address: 'Banani, Dhaka',
        position: const LatLng(23.795, 90.404),
        category: FoodCategory.soups),
    PlaceLocation(
        id: 'p3',
        name: 'Fresh Sips',
        address: 'Dhanmondi, Dhaka',
        position: const LatLng(23.740, 90.375),
        category: FoodCategory.drinks),
    PlaceLocation(
        id: 'p4',
        name: 'Green Bowl',
        address: 'Uttara, Dhaka',
        position: const LatLng(23.870, 90.399),
        category: FoodCategory.salads),
    PlaceLocation(
        id: 'p5',
        name: 'Munchies Hub',
        address: 'Mirpur, Dhaka',
        position: const LatLng(23.806, 90.366),
        category: FoodCategory.snacks),
    PlaceLocation(
        id: 'p6',
        name: 'Broth Bros',
        address: 'Motijheel, Dhaka',
        position: const LatLng(23.726, 90.421),
        category: FoodCategory.soups),
  ];

  return allPlaces
      .where((p) => p.category == filter.selectedCategory)
      .toList();
});

final mapMarkersProvider = Provider<Set<Marker>>((ref) {
  final places = ref.watch(nearbyPlacesProvider);
  return places
      .map(
        (p) => Marker(
      markerId: MarkerId(p.id),
      position: p.position,
      infoWindow: InfoWindow(title: p.name, snippet: p.address),
    ),
  )
      .toSet();
});