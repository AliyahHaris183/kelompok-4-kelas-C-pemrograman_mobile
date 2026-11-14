import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  /// Gaya garis tepi (mis. tombol Log out).
  final bool isOutlined;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? effectiveOnPressed = isLoading ? null : onPressed;
    final iconData = icon;

    final Widget content = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconData != null) ...[
                Icon(iconData, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    if (isOutlined) {
      return OutlinedButton(
        onPressed: effectiveOnPressed,
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        child: content,
      );
    }
    return FilledButton(onPressed: effectiveOnPressed, child: content);
  }
}
