class ChangePasswordStateModel{
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;
  final bool obscureOldPassword;
  final bool obscureNewPassword;
  final bool obscureConfirmPassword;
  final bool isLoading;
  final String? errorMessage;

  ChangePasswordStateModel({
    this.oldPassword = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.obscureOldPassword = true,
    this.obscureNewPassword = true,
    this.obscureConfirmPassword = true,
    this.isLoading = false,
    this.errorMessage,
  });

  ChangePasswordStateModel copyWith({
    String? oldPassword,
    String? newPassword,
    String? confirmPassword,
    bool? obscureOldPassword,
    bool? obscureNewPassword,
    bool? obscureConfirmPassword,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChangePasswordStateModel(
      oldPassword: oldPassword ?? this.oldPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      obscureOldPassword: obscureOldPassword ?? this.obscureOldPassword,
      obscureNewPassword: obscureNewPassword ?? this.obscureNewPassword,
      obscureConfirmPassword: obscureConfirmPassword ?? this.obscureConfirmPassword,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}