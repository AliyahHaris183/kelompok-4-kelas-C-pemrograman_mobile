import 'package:flutter/material.dart';

/// Tombol berbentuk pil. Bawaan: hitam penuh (tombol "Continue" pada Figma).
/// [isOutlined]: gaya garis tepi, untuk aksi sekunder (mis. "Back").
class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;

  static const TextStyle _textStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  @override
  Widget build(BuildContext context) {
    final VoidCallback? effectiveOnPressed = isLoading ? null : onPressed;

    if (isOutlined) {
      return OutlinedButton(
        onPressed: effectiveOnPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          side: const BorderSide(color: Colors.black),
          minimumSize: const Size.fromHeight(44),
          shape: const StadiumBorder(),
          textStyle: _textStyle,
        ),
        child: Text(label),
      );
    }

    return FilledButton(
      onPressed: effectiveOnPressed,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.black,
        disabledForegroundColor: Colors.white,
        minimumSize: const Size.fromHeight(44),
        shape: const StadiumBorder(),
        textStyle: _textStyle,
      ),
      child: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(label),
    );
  }
}
