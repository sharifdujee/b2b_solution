
import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: CustomText(text: "OnBoarding Screen"),
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        context.push('/nav');
      },
      child: Icon(Icons.nat),),
    );
  }
}
