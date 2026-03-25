class SignupStateModel {
  final String legalName;
  final String businessName;
  final String name;
  final String email;
  final String position;
  final String foodCategory;
  final String yearsOfOperation;
  final String businessImage;
  final String profileImage;
  final String businessLicenseImage;
  final String password;
  final String confirmPassword;
  final bool isLoading;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final String? errorMessage;

  SignupStateModel({
    this.legalName = '',
    this.businessName = '',
    this.name = '',
    this.email = '',
    this.position = '',
    this.foodCategory = '',
    this.yearsOfOperation = '',
    this.businessImage = '',
    this.profileImage = '',
    this.businessLicenseImage = '',
    this.password = '',
    this.confirmPassword = '',
    this.isLoading = false,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.errorMessage,
  });

  SignupStateModel copyWith({
    String? legalName,
    String? businessName,
    String? name,
    String? email,
    String? position,
    String? foodCategory,
    String? yearsOfOperation,
    String? businessImage,
    String? profileImage,
    String? businessLicenseImage,
    String? password,
    String? confirmPassword,
    bool? isLoading,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    String? errorMessage,
    bool clearError = false,
  }){
    return SignupStateModel(
      legalName: legalName ?? this.legalName,
        businessName: businessName ?? this.businessName,
        name: name ?? this.name,
        email: email ?? this.email,
        position: position ?? this.position,
        foodCategory: foodCategory ?? this.foodCategory,
        yearsOfOperation: yearsOfOperation ?? this.yearsOfOperation,
        businessImage: businessImage ?? this.businessImage,
        profileImage: profileImage ?? this.profileImage,
        businessLicenseImage: businessLicenseImage ?? this.businessLicenseImage,
        password: password ?? this.password,
        confirmPassword: confirmPassword ?? this.confirmPassword,
        isLoading: isLoading ?? this.isLoading,
        obscurePassword: obscurePassword ?? this.obscurePassword,
        obscureConfirmPassword: obscureConfirmPassword ?? this.obscureConfirmPassword,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}