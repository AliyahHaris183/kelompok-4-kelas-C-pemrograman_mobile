import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/core/constants/app_assets.dart';
import 'package:catlendar/core/errors/app_exception.dart';
import 'package:catlendar/features/auth/presentation/providers/auth_controller.dart';
import 'package:catlendar/features/auth/presentation/providers/auth_providers.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_button.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_link.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_mascot.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_scaffold.dart';

/// Layar 7: Verifikasi email lewat tautan (bukan OTP, keputusan 7.1).
/// Continue memeriksa status verifikasi. Sediakan kirim ulang email.
class EmailVerificationScreen extends ConsumerWidget {
  const EmailVerificationScreen({super.key});

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _errorMessage(WidgetRef ref, String fallback) {
    final error = ref.read(authControllerProvider).error;
    return error == null ? fallback : AppException.from(error).message;
  }

  Future<void> _continue(BuildContext context, WidgetRef ref) async {
    final destination =
        await ref.read(authControllerProvider.notifier).checkEmailVerified();
    if (!context.mounted) return;

    if (destination == null) {
      _showMessage(context, _errorMessage(ref, 'Gagal memeriksa status email.'));
      return;
    }
    switch (destination) {
      case PostLoginDestination.verifyEmail:
        _showMessage(
          context,
          'Email belum terverifikasi. Buka tautan di email Anda '
          '(periksa juga folder spam).',
        );
      case PostLoginDestination.setupProfile:
        context.go(AppRoutes.setupProfile.path);
      case PostLoginDestination.greeting:
        context.go(AppRoutes.greeting.path);
    }
  }

  Future<void> _resend(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(authControllerProvider.notifier).resendVerification();
    if (!context.mounted) return;
    _showMessage(
      context,
      ok
          ? 'Verification email sent again.'
          : _errorMessage(ref, 'Gagal mengirim ulang email.'),
    );
  }

  Future<void> _useAnotherAccount(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(authControllerProvider.notifier).signOut();
    if (!context.mounted) return;
    if (ok) {
      context.go(AppRoutes.login.path);
    } else {
      _showMessage(context, _errorMessage(ref, 'Gagal keluar dari akun.'));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final email = ref.watch(authRepositoryProvider).currentUser?.email;

    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthMascot(assetPath: AppAssets.catSignup),
          const SizedBox(height: 8),
          const Text(
            'Verify your email',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            email == null
                ? "We've sent a verification link to your email."
                : "We've sent a verification link to $email.",
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B6B6B)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Open the link, then tap Continue.',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B6B6B)),
          ),
          const SizedBox(height: 20),
          AuthButton(
            label: 'Continue',
            isLoading: isLoading,
            onPressed: () => _continue(context, ref),
          ),
          const SizedBox(height: 12),
          Center(
            child: AuthLink(
              label: 'Resend verification email',
              onPressed: isLoading ? null : () => _resend(context, ref),
            ),
          ),
          Center(
            child: AuthLink(
              label: 'Use another account',
              onPressed: isLoading ? null : () => _useAnotherAccount(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}
