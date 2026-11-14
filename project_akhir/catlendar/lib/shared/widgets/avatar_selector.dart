import 'package:flutter/material.dart';

/// Pemilih avatar preset. Generik: daftar id diberikan pemanggil
/// (lihat AvatarPresets), dan tampilan avatar dapat diganti lewat
/// [avatarBuilder] setelah aset Figma tersedia.
class AvatarSelector extends StatelessWidget {
  const AvatarSelector({
    super.key,
    required this.avatarIds,
    required this.selectedId,
    required this.onChanged,
    this.avatarBuilder,
    this.size = 56,
  });

  final List<String> avatarIds;
  final String? selectedId;
  final ValueChanged<String> onChanged;
  final Widget Function(BuildContext context, String avatarId)? avatarBuilder;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final builder = avatarBuilder ?? _defaultAvatar;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final id in avatarIds)
          Semantics(
            label: 'Avatar $id',
            selected: id == selectedId,
            button: true,
            child: InkResponse(
              onTap: () => onChanged(id),
              child: Container(
                width: size,
                height: size,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: id == selectedId
                        ? colorScheme.primary
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: ClipOval(child: builder(context, id)),
              ),
            ),
          ),
      ],
    );
  }

  static Widget _defaultAvatar(BuildContext context, String avatarId) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.secondaryContainer,
      child: Icon(Icons.pets, color: colorScheme.onSecondaryContainer),
    );
  }
}
