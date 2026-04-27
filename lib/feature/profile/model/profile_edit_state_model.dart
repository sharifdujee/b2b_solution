import 'package:google_maps_flutter/google_maps_flutter.dart';

class ProfileEditStateModel {
  final String legalName;
  final String businessName;
  final String name;
  final String email;
  final String verificationCode;
  final String position;
  // CHANGED: Changed from String to List<String> for multi-select
  final List<String> businessCategories;
  final String yearsOfOperation;
  final String businessImage;
  final String profileImage;
  final String businessLicenseImage;
  final String password;
  final String confirmPassword;

  // --- Location Fields ---
  final double? latitude;
  final double? longitude;
  final String businessAddress;

  // --- Map & Search UI State ---
  final String searchQuery;
  final List<dynamic> suggestions;
  final dynamic selectedLocation;
  final bool isSearching;
  final LatLng cameraPosition;

  final bool isLoading;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final String? errorMessage;
  final int timer;
  final bool canResend;

  ProfileEditStateModel({
    this.legalName = '',
    this.businessName = '',
    this.name = '',
    this.email = '',
    this.verificationCode = '',
    this.position = '',
    // CHANGED: Initialized as empty list
    this.businessCategories = const [],
    this.yearsOfOperation = '',
    this.businessImage = '',
    this.profileImage = '',
    this.businessLicenseImage = '',
    this.password = '',
    this.confirmPassword = '',
    this.latitude,
    this.longitude,
    this.businessAddress = '',
    this.searchQuery = '',
    this.suggestions = const [],
    this.selectedLocation,
    this.isSearching = false,
    this.cameraPosition = const LatLng(0.0, 0.0),
    this.isLoading = false,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.errorMessage,
    this.timer = 0,
    this.canResend = false,
  });

  ProfileEditStateModel copyWith({
    String? legalName,
    String? businessName,
    String? name,
    String? email,
    String? verificationCode,
    String? position,
    // CHANGED: Updated type to List<String>
    List<String>? businessCategories,
    String? yearsOfOperation,
    String? businessImage,
    String? profileImage,
    String? businessLicenseImage,
    String? password,
    String? confirmPassword,
    double? latitude,
    double? longitude,
    String? businessAddress,
    String? searchQuery,
    List<dynamic>? suggestions,
    dynamic selectedLocation,
    bool? isSearching,
    LatLng? cameraPosition,
    bool? isLoading,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    String? errorMessage,
    int? timer,
    bool? canResend,
    bool clearError = false,
  }) {
    return ProfileEditStateModel(
      legalName: legalName ?? this.legalName,
      businessName: businessName ?? this.businessName,
      name: name ?? this.name,
      email: email ?? this.email,
      verificationCode: verificationCode ?? this.verificationCode,
      position: position ?? this.position,
      // CHANGED: Mapping the new list
      businessCategories: businessCategories ?? this.businessCategories,
      yearsOfOperation: yearsOfOperation ?? this.yearsOfOperation,
      businessImage: businessImage ?? this.businessImage,
      profileImage: profileImage ?? this.profileImage,
      businessLicenseImage: businessLicenseImage ?? this.businessLicenseImage,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      businessAddress: businessAddress ?? this.businessAddress,
      searchQuery: searchQuery ?? this.searchQuery,
      suggestions: suggestions ?? this.suggestions,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      isSearching: isSearching ?? this.isSearching,
      cameraPosition: cameraPosition ?? this.cameraPosition,
      isLoading: isLoading ?? this.isLoading,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword: obscureConfirmPassword ?? this.obscureConfirmPassword,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      timer: timer ?? this.timer,
      canResend: canResend ?? this.canResend,
    );
  }
}