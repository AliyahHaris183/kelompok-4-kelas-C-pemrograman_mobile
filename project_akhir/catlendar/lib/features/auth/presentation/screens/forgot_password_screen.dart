import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/core/errors/app_exception.dart';
import 'package:catlendar/core/utils/validators.dart';
import 'package:catlendar/features/auth/presentation/providers/auth_controller.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_button.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_mascot.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_text_field.dart';

/// Layar 4: Forgot password. Masukkan email, lalu kirim tautan reset.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final ok = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(_emailController.text);
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    if (!ok) {
      final error = ref.read(authControllerProvider).error;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error == null
                ? 'Gagal mengirim tautan. Coba lagi.'
                : AppException.from(error).message,
          ),
        ),
      );
      return;
    }

    // Pesan netral: tidak membocorkan apakah email terdaftar atau tidak.
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'If an account exists for this email, a reset link has been sent.',
        ),
      ),
    );
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return AuthScaffold(
      showBack: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AuthMascot(assetPath: 'assets/images/cat_signup.png'),
            const SizedBox(height: 8),
            const Text(
              'Forgot password',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              "Enter your email and we'll send you a link to reset your password.",
              style: TextStyle(fontSize: 12, color: Color(0xFF6B6B6B)),
            ),
            const SizedBox(height: 20),
            AuthTextField(
              controller: _emailController,
              hint: 'Email',
              icon: Icons.mail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              enabled: !isLoading,
              validator: Validators.email,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            AuthButton(
              label: 'Continue',
              isLoading: isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
