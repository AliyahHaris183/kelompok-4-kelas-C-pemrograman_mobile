import 'package:flutter/material.dart';

/// Pilihan tunggal berbentuk pil (mis. Gender). Terpilih: hitam.
class AuthOptionSelector extends StatelessWidget {
  const AuthOptionSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<String> options;
  final String? selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          ChoiceChip(
            label: Text(option),
            selected: option == selected,
            showCheckmark: false,
            onSelected: (_) => onChanged(option),
            selectedColor: Colors.black,
            backgroundColor: Colors.white,
            shape: const StadiumBorder(
              side: BorderSide(color: Color(0xFFD0D0D0)),
            ),
            labelStyle: TextStyle(
              fontSize: 12,
              color: option == selected ? Colors.white : Colors.black,
            ),
          ),
      ],
    );
  }
}
