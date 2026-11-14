import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/shared/widgets/confirm_dialog.dart';

/// Konfirmasi log out dari Settings (layar 24 pada dokumen alur).
Future<void> confirmAndLogout(BuildContext context, WidgetRef ref) async {
  final confirmed = await ConfirmDialog.show(
    context,
    title: 'Log out',
    message: 'Yakin ingin keluar dari akun?',
    confirmLabel: 'Log out',
    isDestructive: true,
  );
  if (!confirmed || !context.mounted) return;

  // TODO(Orang 1): setelah konfirmasi:
  //  1. hapus fcm_token di USERS (UserRepository.updateFcmToken dengan null)
  //  2. ref.read(authRepositoryProvider).signOut()
  //  3. kembali ke Welcome: context.go(AppRoutes.welcome.path)
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('TODO(Orang 1): log out belum diimplementasikan.'),
    ),
  );
}
