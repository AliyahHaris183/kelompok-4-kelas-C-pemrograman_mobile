import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/core/constants/app_assets.dart';
import 'package:catlendar/core/errors/app_exception.dart';
import 'package:catlendar/core/utils/validators.dart';
import 'package:catlendar/features/auth/presentation/providers/auth_controller.dart';
import 'package:catlendar/features/auth/presentation/providers/profile_providers.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_button.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_mascot.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_text_field.dart';

/// Layar 6: Please create a password.
/// Validasi: minimal 6 karakter, konfirmasi harus sama. Membuat akun lalu
/// mengirim tautan verifikasi ke email.
class CreatePasswordScreen extends ConsumerStatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  ConsumerState<CreatePasswordScreen> createState() =>
      _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends ConsumerState<CreatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final email = ref.read(signUpEmailProvider);
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi email dulu di layar Sign up.')),
      );
      context.go(AppRoutes.signup.path);
      return;
    }

    final ok = await ref
        .read(authControllerProvider.notifier)
        .signUp(email: email, password: _passwordController.text);
    if (!mounted) return;

    if (!ok) {
      final error = ref.read(authControllerProvider).error;
      final appError = error == null ? null : AppException.from(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appError?.message ?? 'Gagal membuat akun. Coba lagi.'),
        ),
      );
      // Email sudah terdaftar: kembali ke Sign up agar bisa mengganti email.
      if (appError?.code == 'email-already-in-use' && context.canPop()) {
        context.pop();
      }
      return;
    }

    ref.read(signUpEmailProvider.notifier).clear();
    context.go(AppRoutes.emailVerification.path);
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
            const AuthMascot(assetPath: AppAssets.catSignup),
            const SizedBox(height: 8),
            const Text(
              'Please create a password',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            AuthTextField(
              controller: _passwordController,
              hint: 'Password',
              icon: Icons.lock,
              isPassword: true,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              enabled: !isLoading,
              validator: Validators.password,
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _confirmController,
              hint: 'Confirm password',
              icon: Icons.lock,
              isPassword: true,
              textInputAction: TextInputAction.done,
              enabled: !isLoading,
              validator: (value) =>
                  Validators.confirmPassword(value, _passwordController.text),
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
