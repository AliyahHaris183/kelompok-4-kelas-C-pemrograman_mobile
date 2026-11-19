import 'package:flutter/material.dart';

/// Banner peringatan saat Firebase belum terkonfigurasi. Layar placeholder
/// tetap bisa dibuka; fitur yang membaca Firebase akan gagal sampai setup
/// selesai (lihat docs/firebase_setup.md).
class FirebaseStatusBanner extends StatelessWidget {
  const FirebaseStatusBanner({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.errorContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            'Firebase belum terkonfigurasi. Lihat docs/firebase_setup.md.'
            '${message == null ? '' : '\n$message'}',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onErrorContainer,
            ),
          ),
        ),
      ),
    );
  }
}
