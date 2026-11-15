import 'package:flutter/material.dart';

enum GradientBackdropStyle {
  /// Layar Hello: lingkaran jingga-kuning di tengah, tepi krem.
  hello,

  /// Layar Welcome dan Greeting: gradasi merah muda ke putih.
  welcome,
}

/// Latar gradasi layar Hello, Welcome, dan Greeting.
/// PLACEHOLDER: warna diperkirakan dari screenshot Figma. Ganti dengan nilai
/// dari panel Inspect Figma bila ada yang meleset.
class GradientBackdrop extends StatelessWidget {
  const GradientBackdrop({super.key, required this.style, required this.child});

  final GradientBackdropStyle style;
  final Widget child;

  Gradient get _gradient => switch (style) {
        GradientBackdropStyle.hello => const RadialGradient(
            center: Alignment(0, 0.05),
            radius: 0.8,
            colors: [
              Color(0xFFFF9B7D),
              Color(0xFFFFC98A),
              Color(0xFFFFF1B8),
              Color(0xFFFFFEF5),
            ],
            stops: [0, 0.35, 0.7, 1],
          ),
        GradientBackdropStyle.welcome => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF7709E),
              Color(0xFFFA9A85),
              Color(0xFFF56FA5),
              Color(0xFFFFE9EF),
              Colors.white,
            ],
            stops: [0, 0.3, 0.6, 0.85, 1],
          ),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: _gradient),
        child: SafeArea(child: child),
      ),
    );
  }
}
