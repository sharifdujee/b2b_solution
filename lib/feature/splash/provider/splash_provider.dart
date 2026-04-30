import 'package:flutter_riverpod/legacy.dart';

import '../../../core/service/auth_service.dart';

enum AppStartupState { loading, authenticated, unauthenticated }

class AppStartupNotifier extends StateNotifier<AppStartupState> {
  AppStartupNotifier() : super(AppStartupState.loading) {
    _init();
  }

  final minimumWait = Future.delayed(const Duration(seconds: 2));


  Future<void> _init() async {


    await AuthService.init();
    await minimumWait;

    // 2. Check for token
    if (AuthService.hasToken()) {
      state = AppStartupState.authenticated;
    } else {
      state = AppStartupState.unauthenticated;
    }
  }
}

final splashProvider = StateNotifierProvider<AppStartupNotifier, AppStartupState>((ref) {
  return AppStartupNotifier();
});