import 'package:b2b_solution/feature/authentication/presentation/screen/business_location_map_view.dart';
import 'package:b2b_solution/feature/authentication/presentation/screen/signup_screen.dart';
import 'package:b2b_solution/feature/profile/presentation/screen/privacy_policy.dart';
import 'package:b2b_solution/feature/profile/presentation/screen/terms_conditions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../authentication/presentation/screen/create_new_password_screen.dart';
import '../authentication/presentation/screen/location_access_screen.dart';
import '../authentication/presentation/screen/login_screen.dart';
import '../authentication/presentation/screen/reset_password.dart';
import '../authentication/presentation/screen/reset_verification_code_screen.dart';
import '../authentication/presentation/screen/signup_verification_code_screen.dart';
import '../navigation/presentation/screen.dart';
import '../onboarding/presentation/screen/onboarding_screen.dart';
import '../ping/model/ping_model.dart';
import '../ping/presentation/screen/create_ping_screen.dart';
import '../ping/presentation/screen/ping_details.dart';
import '../profile/presentation/screen/change_password_screen.dart';
import '../profile/presentation/screen/edit_profile_screen.dart';
import '../profile/presentation/screen/help_center_screen.dart';
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
        builder: (context, state) => const NavBar(), // ✅ real navbar
      ),


      GoRoute(path: "/locationAccessScreen", builder: (context, state)=> LocationAccessScreen()),
      GoRoute(path: '/loginScreen', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/signupScreen', builder: (context, state) => SignupScreen()),

      GoRoute(path: '/resetPassword', builder: (context, state) => ResetPassword()),
      GoRoute(path: '/resetVerificationCodeScreen', builder: (context, state) => ResetVerificationCodeScreen()),


      GoRoute(path: '/businessLocation', builder: (context, state) => BusinessLocationMapView()),
      GoRoute(path: "/createNewPasswordScreen", builder: (context, state)=> CreateNewPasswordScreen()),

      GoRoute(path: "/signupVerificationCodeScreen", builder: (context, state)=> SignupVerificationCodeScreen()),
      GoRoute(path: "/editProfile",builder: (context, state)=> EditProfile()),
      GoRoute(path: "/changePasswordScreen", builder: (context, state)=> ChangePasswordScreen()),
      GoRoute(path: "/helpCenterScreen", builder: (context, state)=> HelpCenterScreen()),
      GoRoute(path: "/privacyPolicy", builder: (context, state)=> PrivacyPolicy()),
      GoRoute(path: "/terms", builder: (context, state)=> TermsConditions()),

      GoRoute(
        path: '/pingDetails',
        builder: (context, state) {
          // Retrieve the PingModel from the extra parameter
          final ping = state.extra as PingModel;
          return PingDetails(ping: ping);
        },
      ),
      GoRoute(path: "/createPingScreen",builder: (context,state)=> CreatePingScreen()),


    ],
  );
});