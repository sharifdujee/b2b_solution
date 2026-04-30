class CompleteProfileState {
  final bool isLoading;
  final String? errorMessage;
  final String? profileImage;
  final String? businessImage;
  final String? businessAddress;
  // Added for API compatibility
  final double? latitude;
  final double? longitude;
  // Synced with your UI variable names
  final List<String> foodCategory;

  CompleteProfileState({
    this.isLoading = false,
    this.errorMessage,
    this.profileImage,
    this.businessImage,
    this.businessAddress,
    this.latitude,
    this.longitude,
    this.foodCategory = const [],
  });

  CompleteProfileState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? profileImage,
    String? businessImage,
    String? businessAddress,
    double? latitude,
    double? longitude,
    List<String>? foodCategory,
  }) {
    return CompleteProfileState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Overwrites to null if not provided
      profileImage: profileImage ?? this.profileImage,
      businessImage: businessImage ?? this.businessImage,
      businessAddress: businessAddress ?? this.businessAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      foodCategory: foodCategory ?? this.foodCategory,
    );
  }
}