

import 'package:flutter_riverpod/legacy.dart';


final splashProvider =
StateNotifierProvider<AppStartupNotifier, bool>((ref) {
  return AppStartupNotifier();
});

class AppStartupNotifier extends StateNotifier<bool> {
  AppStartupNotifier() : super(true) {
    _init();
  }

  Future<void> _init() async {
   /// await AuthService.init(); // VERY important

    await Future.delayed(const Duration(seconds: 2));

    state = false; // loading finished
  }
}