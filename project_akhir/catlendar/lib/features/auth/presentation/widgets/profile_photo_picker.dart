import 'package:flutter/material.dart';

import 'package:catlendar/core/constants/avatar_presets.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_link.dart';
import 'package:catlendar/shared/widgets/avatar_image.dart';
import 'package:catlendar/shared/widgets/avatar_selector.dart';

enum _PhotoAction { gallery, preset }

/// Foto profil besar berbentuk lingkaran dengan tautan "Edit profile picture"
/// (sesuai Figma layar Set up your profile dan Settings).
///
/// Tautan membuka pilihan: ambil dari galeri (diunggah ke Cloudinary) atau
/// pilih avatar preset. Widget ini tidak melakukan unggah sendiri; pemanggil
/// mengisi [onChooseFromGallery] dan [onChoosePreset].
class ProfilePhotoPicker extends StatelessWidget {
  const ProfilePhotoPicker({
    super.key,
    required this.avatarId,
    required this.onChooseFromGallery,
    required this.onChoosePreset,
    this.isUploading = false,
    this.size = 140,
  });

  final String? avatarId;
  final VoidCallback onChooseFromGallery;
  final ValueChanged<String> onChoosePreset;

  /// Menampilkan indikator di atas foto dan menonaktifkan tautan.
  final bool isUploading;
  final double size;

  Future<void> _showOptions(BuildContext context) async {
    final action = await showModalBottomSheet<_PhotoAction>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(sheetContext).pop(_PhotoAction.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('Choose a preset avatar'),
              onTap: () => Navigator.of(sheetContext).pop(_PhotoAction.preset),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted) return;

    switch (action) {
      case _PhotoAction.gallery:
        onChooseFromGallery();
      case _PhotoAction.preset:
        await _showPresets(context);
      case null:
        break;
    }
  }

  Future<void> _showPresets(BuildContext context) async {
    final id = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AvatarSelector(
            avatarIds: AvatarPresets.ownerAvatarIds,
            selectedId: avatarId,
            avatarBuilder: (context, id) => AvatarImage(avatarId: id),
            onChanged: (selected) => Navigator.of(sheetContext).pop(selected),
          ),
        ),
      ),
    );
    if (id != null) onChoosePreset(id);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            AvatarImage(avatarId: avatarId, size: size),
            if (isUploading)
              Container(
                width: size,
                height: size,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black38,
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        AuthLink(
          label: 'Edit profile picture',
          fontSize: 13,
          onPressed: isUploading ? null : () => _showOptions(context),
        ),
      ],
    );
  }
}
