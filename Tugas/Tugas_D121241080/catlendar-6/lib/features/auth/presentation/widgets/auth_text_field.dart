import 'package:flutter/material.dart';

/// Field berbentuk pil dengan ikon di kiri, sesuai desain Figma.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.hint,
    required this.icon,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.isPassword = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofillHints,
    this.onSubmitted,
    this.onTap,
  });

  final String hint;
  final IconData icon;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;

  /// Menyembunyikan teks dan menampilkan tombol lihat/sembunyikan.
  final bool isPassword;
  final bool enabled;

  /// Dipakai untuk field yang diisi lewat layar lain (mis. tanggal lahir).
  final bool readOnly;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  static const Color _borderColor = Color(0xFFD0D0D0);
  static const Color _hintColor = Color(0xFF8E8E93);

  bool _obscure = true;

  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(28)),
        borderSide: BorderSide(color: color),
      );

  @override
  Widget build(BuildContext context) {
    final Widget? suffix = widget.isPassword
        ? IconButton(
            iconSize: 18,
            color: _hintColor,
            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscure = !_obscure),
          )
        : null;

    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      obscureText: widget.isPassword && _obscure,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofillHints: widget.autofillHints,
      onFieldSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(fontSize: 12, color: _hintColor),
        prefixIcon: Icon(widget.icon, size: 16, color: _hintColor),
        suffixIcon: suffix,
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        errorStyle: const TextStyle(fontSize: 11),
        border: _border(_borderColor),
        enabledBorder: _border(_borderColor),
        disabledBorder: _border(_borderColor),
        focusedBorder: _border(Colors.black),
        errorBorder: _border(Theme.of(context).colorScheme.error),
        focusedErrorBorder: _border(Theme.of(context).colorScheme.error),
      ),
    );
  }
}
