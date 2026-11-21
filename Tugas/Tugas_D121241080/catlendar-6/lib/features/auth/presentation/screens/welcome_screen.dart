import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/core/constants/app_assets.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_mascot.dart';
import 'package:catlendar/features/auth/presentation/widgets/gradient_backdrop.dart';

/// Layar 2: Welcome to Catlendar. Logo kucing, lalu otomatis lanjut ke Log in.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) context.go(AppRoutes.login.path);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const GradientBackdrop(
      style: GradientBackdropStyle.welcome,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AuthMascot(
              assetPath: AppAssets.catWelcome,
              size: 64,
              alignment: Alignment.center,
              fallbackColor: Colors.white,
            ),
            SizedBox(height: 12),
            Text(
              'Welcome to\nCatlendar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
