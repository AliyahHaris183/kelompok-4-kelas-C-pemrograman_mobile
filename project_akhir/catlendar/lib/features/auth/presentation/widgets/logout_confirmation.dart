import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/core/errors/app_exception.dart';
import 'package:catlendar/features/auth/presentation/providers/auth_controller.dart';
import 'package:catlendar/shared/widgets/confirm_dialog.dart';

/// Log out dari Settings (layar 24): konfirmasi, hapus fcm_token, sign out,
/// lalu kembali ke Welcome.
Future<void> confirmAndLogout(BuildContext context, WidgetRef ref) async {
  final confirmed = await ConfirmDialog.show(
    context,
    title: 'Log out',
    message: 'Yakin ingin keluar dari akun?',
    confirmLabel: 'Log out',
    isDestructive: true,
  );
  if (!confirmed || !context.mounted) return;

  final ok = await ref.read(authControllerProvider.notifier).logout();
  if (!context.mounted) return;

  if (!ok) {
    final error = ref.read(authControllerProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error == null
              ? 'Gagal log out. Coba lagi.'
              : AppException.from(error).message,
        ),
      ),
    );
    return;
  }

  // Router (route_guard.dart) juga mengarahkan ke Welcome saat status berubah;
  // navigasi eksplisit ini menuju tujuan yang sama.
  context.go(AppRoutes.welcome.path);
}
