class LoginStateModel {
  final String email;
  final String password;
  final bool isLoading;
  final bool obscurePassword;
  final String? errorMessage;

  LoginStateModel({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.obscurePassword = true,
    this.errorMessage,
  });

  LoginStateModel copyWith({
    String? email,
    String? password,
    bool? isLoading,
    bool? obscurePassword,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoginStateModel(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}