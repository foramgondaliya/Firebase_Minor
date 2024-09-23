import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  User? user;

  void checkAuthStatus() {
    user = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late Timer timer;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    timer = Timer.periodic(
      const Duration(seconds: 4),
      (timer) {
        (FirebaseAuth.instance.currentUser != null)
            ? Navigator.of(context).pushReplacementNamed("/")
            : Navigator.of(context).pushReplacementNamed("Login_Page");
        timer.cancel();
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.5, end: 1.0), // Scaling the logo
          duration: const Duration(seconds: 2),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Container(
            height: 200,
            width: 200,
            child: Image.asset(
              fit: BoxFit.cover,
              "assets/image/logo.webp",
            ),
          ),
        ),
      ),
    );
  }
}
