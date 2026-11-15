import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/features/auth/presentation/widgets/gradient_backdrop.dart';

/// Layar 1: Hello. Latar gradasi, lalu otomatis lanjut ke Welcome.
///
/// TODO(Orang 1): setelah redirect router (tahap 3) selesai, pengguna yang
/// sudah login tidak perlu melihat layar ini.
class HelloScreen extends StatefulWidget {
  const HelloScreen({super.key});

  @override
  State<HelloScreen> createState() => _HelloScreenState();
}

class _HelloScreenState extends State<HelloScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) context.go(AppRoutes.welcome.path);
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
      style: GradientBackdropStyle.hello,
      child: Center(
        child: Text(
          'Hello.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
