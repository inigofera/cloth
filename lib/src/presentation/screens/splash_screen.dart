import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import 'welcome_screen.dart';
import 'home_screen.dart';

/// Splash screen that manages the welcome screen timing and transition
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    // Navigate to home screen after the full duration
    Future.delayed(
      Duration(seconds: AppConstants.welcomeScreenDurationSeconds),
      () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const HomeScreen(),
              transitionDuration: const Duration(milliseconds: 500),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const WelcomeScreen();
  }
}
