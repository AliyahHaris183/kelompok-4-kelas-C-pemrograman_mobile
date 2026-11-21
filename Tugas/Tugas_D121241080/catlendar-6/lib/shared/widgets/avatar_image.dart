import 'package:flutter/material.dart';

import 'package:catlendar/core/constants/app_assets.dart';
import 'package:catlendar/shared/widgets/owner_avatar.dart';

/// Menampilkan avatar berbentuk lingkaran dari nilai avatar_id.
///
/// avatar_id bisa berisi:
///  - URL foto (https://...): ditampilkan dari jaringan,
///  - id avatar pemilik (owner_1 sampai owner_8): digambar lewat kode
///    (OwnerAvatar), tanpa file gambar,
///  - id lain (mis. avatar kucing): gambar assets/images/avatars/id.png
///    (lihat AppAssets.avatar),
///  - kosong: ikon orang.
/// Jika gambar gagal dimuat, ikon cadangan ditampilkan.
class AvatarImage extends StatelessWidget {
  const AvatarImage({super.key, required this.avatarId, this.size = 56});

  final String? avatarId;
  final double size;

  /// True jika [value] adalah URL foto, bukan id avatar preset.
  static bool isPhotoUrl(String? value) =>
      value != null &&
      (value.startsWith('https://') || value.startsWith('http://'));

  @override
  Widget build(BuildContext context) {
    final id = avatarId;
    final Widget content;

    if (id != null && isPhotoUrl(id)) {
      content = Image.network(
        id,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorBuilder: (context, error, stackTrace) =>
            _placeholder(context, hasPreset: false),
      );
    } else if (id != null && OwnerAvatar.supports(id)) {
      content = OwnerAvatar(avatarId: id);
    } else if (id != null && id.isNotEmpty) {
      content = Image.asset(
        AppAssets.avatar(id),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _placeholder(context, hasPreset: true),
      );
    } else {
      content = _placeholder(context, hasPreset: false);
    }

    return ClipOval(
      child: SizedBox(width: size, height: size, child: content),
    );
  }

  Widget _placeholder(BuildContext context, {required bool hasPreset}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.secondaryContainer,
      child: Icon(
        hasPreset ? Icons.pets : Icons.person,
        size: size * 0.5,
        color: colorScheme.onSecondaryContainer,
      ),
    );
  }
}
