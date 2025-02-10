import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gaushalascanner/pages/login_page.dart';
import 'package:gaushalascanner/pages/scanner_page.dart';
import 'package:gaushalascanner/utils/Login/session_manager.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        navigationWidget();
      }
    });
  }

  void navigationWidget() async {
    final sessionManager = Provider.of<SessionManager>(context, listen: false);
    String? authToken = sessionManager.authToken;

    if (authToken != null) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const ScannerPage()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(color: Colors.white),
        child: Image(
          image: const AssetImage('assets/images/logo.png'),
          height: MediaQuery.of(context).size.height * 0.120,
          width: MediaQuery.of(context).size.width * 0.05120,
        ),
      ),
    );
  }
}
