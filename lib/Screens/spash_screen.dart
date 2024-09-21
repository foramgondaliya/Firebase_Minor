import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

class _SplashScreenState extends State<SplashScreen> {
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) {
        (FirebaseAuth.instance.currentUser != null)
            ? Navigator.of(context).pushReplacementNamed("/")
            : Navigator.of(context).pushReplacementNamed("Login_Page");
        timer.cancel();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
