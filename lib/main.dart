import 'package:b2b_solution/core/service/auth_service.dart';
import 'package:b2b_solution/feature/my_app/my_app.dart';
import 'package:b2b_solution/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AuthService.init();

  runApp(
    ProviderScope(child: MyApp()),
  );
}

