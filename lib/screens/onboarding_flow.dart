import 'package:flutter/material.dart';

import 'auth_screen.dart';

class OnboardingFlow extends StatelessWidget {
  const OnboardingFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthScreen();
  }

  static void openAuth(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AuthScreen()),
    );
  }
}
