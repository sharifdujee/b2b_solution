import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../onboarding/presentation/screen/onboarding_screen.dart';
import '../splash/presentation/splash_screen.dart';
import '../splash/provider/splash_provider.dart';


final goRouterProvider = Provider<GoRouter>((ref) {
  final isLoading = ref.watch(splashProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final location = state.matchedLocation;

      // Stay on splash while still loading
      if (isLoading) {
        return location == '/splash' ? null : '/splash';
      }

      // ✅ When loading finishes, redirect to onboarding
      if (location == '/splash') {
        return '/onBoarding';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onBoarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/nav',
        builder: (context, state) => const SplashScreen(), // ✅ real navbar
      ),
    ],
  );
});