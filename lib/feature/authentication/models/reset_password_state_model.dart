class ResetPasswordStateModel {
  final String email;
  final String verificationCode;
  final String password;
  final String confirmPassword;
  final bool isLoading;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final String? errorMessage;
  final bool clearError;


  ResetPasswordStateModel({
    this.email = '',
    this.verificationCode = '',
    this.password = '',
    this.confirmPassword = '',
    this.isLoading = false,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.errorMessage,
    this.clearError = false,

});
  ResetPasswordStateModel copyWith({
    String? email,
    String? verificationCode,
    String? password,
    String? confirmPassword,
    bool clearError = false,
    bool? isLoading,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    String? errorMessage,
  }){
    return ResetPasswordStateModel(
      email :email ?? this.email,
      verificationCode: verificationCode ?? this.verificationCode,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isLoading: isLoading ?? this.isLoading,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword: obscureConfirmPassword ?? this.obscureConfirmPassword,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );

  }

}