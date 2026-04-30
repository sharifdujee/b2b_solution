import 'package:b2b_solution/feature/authentication/presentation/screen/business_location_map_view.dart';
import 'package:b2b_solution/feature/authentication/presentation/screen/complete_profile_info_screen.dart';
import 'package:b2b_solution/feature/authentication/presentation/screen/signup_screen.dart';
import 'package:b2b_solution/feature/home/presentation/screen/map_view_screen.dart';
import 'package:b2b_solution/feature/profile/presentation/screen/edit_profile_business_loation_screen.dart';
import 'package:b2b_solution/feature/profile/presentation/screen/privacy_policy.dart';
import 'package:b2b_solution/feature/profile/presentation/screen/terms_conditions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/service/auth_service.dart';
import '../authentication/presentation/screen/create_new_password_screen.dart';
import '../authentication/presentation/screen/location_access_screen.dart';
import '../authentication/presentation/screen/login_screen.dart';
import '../authentication/presentation/screen/reset_password.dart';
import '../authentication/presentation/screen/reset_verification_code_screen.dart';
import '../authentication/presentation/screen/role_selection_screen.dart';
import '../authentication/presentation/screen/signup_verification_code_screen.dart';
import '../home/model/connected_state_model.dart';
import '../home/model/find_connecion_state_model.dart' show FindDatum;
import '../home/model/pending_connection_state_model.dart';
import '../home/model/send_request_state_model.dart';
import '../home/presentation/screen/connected_business_card.dart';
import '../home/presentation/screen/find_business_card_screen.dart';
import '../home/presentation/screen/my_connection_screen.dart';
import '../home/presentation/screen/notification_screen.dart';
import '../home/presentation/screen/pending_business_card.dart';
import '../home/presentation/screen/request_business_card_screen.dart';
import '../home/presentation/screen/vendors_screen.dart';
import '../message/presentation/screen/chat_screen.dart';
import '../navigation/presentation/screen.dart';
import '../onboarding/presentation/screen/onboarding_screen.dart';
import '../ping/model/ping_model.dart';
import '../ping/presentation/screen/create_ping_by_id.dart';
import '../ping/presentation/screen/create_ping_screen.dart';
import '../ping/presentation/screen/ping_details.dart';
import '../ping/presentation/screen/ping_screen.dart';
import '../profile/presentation/screen/change_password_screen.dart';
import '../profile/presentation/screen/edit_profile_screen.dart';
import '../profile/presentation/screen/help_center_screen.dart';
import '../splash/presentation/splash_screen.dart';
import '../splash/provider/splash_provider.dart';


final goRouterProvider = Provider<GoRouter>((ref) {
  final startupState = ref.watch(splashProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final location = state.matchedLocation;

      if (startupState == AppStartupState.loading) {
        return '/splash';
      }

      if (location == '/splash') {
        if (startupState == AppStartupState.authenticated) {
          return '/nav';
        } else {
          return '/onBoarding';
        }
      }

      // 3. Allow all other navigations
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
      GoRoute(path: '/completeProfileInfoScreen', builder: (context,state) => CompleteProfileInfoScreen()),

      GoRoute(path: '/resetPassword', builder: (context, state) => ResetPassword()),
      GoRoute(path: '/resetVerificationCodeScreen', builder: (context, state) => ResetVerificationCodeScreen()),



      GoRoute(path: '/businessLocation', builder: (context, state) => BusinessLocationMapView()),
      GoRoute(
        path: "/createNewPasswordScreen",
        builder: (context, state) {
          final String token = state.extra as String;
          return CreateNewPasswordScreen(forgetToken: token);
        },
      ),
      GoRoute(path: "/signupVerificationCodeScreen", builder: (context, state)=> SignupVerificationCodeScreen()),
      GoRoute(path: "/roleSelectionScreen", builder: (context, state)=> RoleSelectionScreen()),

      GoRoute(path: "/editProfile",builder: (context, state)=> EditProfile()),
      GoRoute(path: "/editProfileBusinessLocation", builder: (context, state)=> EditProfileBusinessLocationScreen()),
      GoRoute(path: "/changePasswordScreen", builder: (context, state)=> ChangePasswordScreen()),
      GoRoute(path: "/helpCenterScreen", builder: (context, state)=> HelpCenterScreen()),
      GoRoute(path: "/privacyPolicy", builder: (context, state)=> PrivacyPolicy()),
      GoRoute(path: "/terms", builder: (context, state)=> TermsConditions()),
      GoRoute(path: "/mapView", builder: (context, state)=> MapViewScreen()),

      GoRoute(
        path: '/pingDetails',
        builder: (context, state) {
          final datum = state.extra as Datum;
          return PingDetails(ping: datum);
        },
      ),

      GoRoute(
        path: '/createPingForUser/:targetPartnerId',
        name: 'createPingForUser',
        builder: (context, state) {
          final String userId = state.pathParameters['targetPartnerId'] ?? '';

          return CreatePingForUserScreen(
            targetPartnerId: userId,
          );
        },
      ),


      GoRoute(path: "/createPingScreen",builder: (context,state)=> CreatePingScreen()),

      GoRoute(path: "/notificationScreen", builder: (context,state) => NotificationScreen()),

      GoRoute(path: "/myConnectionScreen", builder: (context, state) => MyConnectionScreen()),

      GoRoute(path: "/vendorsScreen", builder: (context, state) => const VendorsScreen()),

      GoRoute(path: "/pingScreen" ,builder: (context, state) => const PingScreen()),

      GoRoute(
          path: "/chatScreen",
          builder: (context, state) {
            final roomId = state.extra as String;
            return ChatScreen(roomId: roomId);
          }
      ),

      GoRoute(
        path: '/findBusinessCard',
        builder: (context, state) {
          final data = state.extra as FindDatum;
          return FindBusinessCardScreen(user: data);
        },
      ),

      GoRoute(
        path: '/requestBusinessCard',
        builder: (context, state) {
          final data = state.extra as SendRequestResultDatum;
          return RequestBusinessCardScreen(request: data);
        },
      ),

// 3. Pending (Incoming) Business Card Route
      GoRoute(
        path: '/pendingBusinessCard',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PendingBusinessCardScreen(
            connection: extra['connection'] as PendingConnection,
            currentUserId: extra['currentUserId'] as String,
          );
        },
      ),

      GoRoute(
        path: '/connectedBusinessCard',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ConnectedBusinessCardScreen(
            connection: extra['connection'] as ConnectedConnection,
            currentUserId: extra['currentUserId'] as String,
          );
        },
      ),
    ],
  );
});