import 'package:flutter/material.dart';

/// Teks tautan kecil bergaris bawah (mis. "Forgot password?").
class AuthLink extends StatelessWidget {
  const AuthLink({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(
          fontSize: 11,
          decoration: TextDecoration.underline,
        ),
      ),
      child: Text(label),
    );
  }
}
