

import 'package:b2b_solution/core/gloabal/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageScreen extends ConsumerWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: CustomText(text: "Message Screen"),
      ),
    );
  }
}
