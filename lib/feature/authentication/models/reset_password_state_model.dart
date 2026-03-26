class ResetPasswordStateModel {
  final String email;
  final String verificationCode;
  final String password;
  final String confirmPassword;
  final bool isLoading;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final String? errorMessage;


  ResetPasswordStateModel({
    this.email = '',
    this.verificationCode = '',
    this.password = '',
    this.confirmPassword = '',
    this.isLoading = false,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,

})
  ResetPasswordStateModel copyWith({
    String? email,
    String? verificationCode,
    String? password,
    String? confirmPassword,
    bool clearError = false,
  }){
    return ResetPasswordStateModel(
      email :email ?? this.email,
    );

  }

}