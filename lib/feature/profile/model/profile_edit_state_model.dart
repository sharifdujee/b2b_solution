class ProfileEditStateModel {
  final String legalName;
  final String businessName;
  final String name;
  final String email;
  final String verificationCode;
  final String position;
  final String foodCategory;
  final String yearsOfOperation;
  final String businessImage;
  final String profileImage;
  final String businessLicenseImage;
  final String password;
  final String confirmPassword;

  // --- Added Location Fields ---
  final double? latitude;
  final double? longitude;
  final String businessAddress;
  // ----------------------------

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
    this.foodCategory = '',
    this.yearsOfOperation = '',
    this.businessImage = '',
    this.profileImage = '',
    this.businessLicenseImage = '',
    this.password = '',
    this.confirmPassword = '',
    this.latitude, // Default null
    this.longitude, // Default null
    this.businessAddress = '',
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
    String? foodCategory,
    String? yearsOfOperation,
    String? businessImage,
    String? profileImage,
    String? businessLicenseImage,
    String? password,
    String? confirmPassword,
    double? latitude, // Added
    double? longitude, // Added
    String? businessAddress, // Added
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
      foodCategory: foodCategory ?? this.foodCategory,
      yearsOfOperation: yearsOfOperation ?? this.yearsOfOperation,
      businessImage: businessImage ?? this.businessImage,
      profileImage: profileImage ?? this.profileImage,
      businessLicenseImage: businessLicenseImage ?? this.businessLicenseImage,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      latitude: latitude ?? this.latitude, // Added
      longitude: longitude ?? this.longitude, // Added
      businessAddress: businessAddress ?? this.businessAddress, // Added
      isLoading: isLoading ?? this.isLoading,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword: obscureConfirmPassword ?? this.obscureConfirmPassword,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      timer: timer ?? this.timer,
      canResend: canResend ?? this.canResend,
    );
  }
}