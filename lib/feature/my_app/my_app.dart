import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/service/push_notification_service.dart';
import '../routing/app_routing.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    debugPrint('🔵 MyApp initState called');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🔵 PostFrameCallback triggered');
      _initializePushNotifications();
    });
  }

  Future<void> _initializePushNotifications() async {
    debugPrint('🔵 Starting push notification initialization...');
    try {
      final notificationService = ref.read(pushNotificationServiceProvider);
      debugPrint('🔵 NotificationService instance obtained: $notificationService');
      await notificationService.initialize();
      debugPrint('✅ Push notifications initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing push notifications: $e');
      debugPrint('❌ StackTrace: $stackTrace');
    }
  }                        // ← closes initState here

  @override                  // ← build is now a separate method
  Widget build(BuildContext context) {
    debugPrint('🔵 MyApp build called');
    final router = ref.watch(goRouterProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          themeMode: ThemeMode.system,
          theme: ThemeData(
            brightness: Brightness.light,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.light,
            useMaterial3: true,
          ),
        );
      },
    );
  }
}                            // ← closes the class