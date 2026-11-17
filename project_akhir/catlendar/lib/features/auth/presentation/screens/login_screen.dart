import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/core/constants/app_assets.dart';
import 'package:catlendar/core/errors/app_exception.dart';
import 'package:catlendar/core/utils/validators.dart';
import 'package:catlendar/features/auth/presentation/providers/auth_controller.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_button.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_link.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_mascot.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_text_field.dart';

/// Layar 3: Log in to your account.
///
/// Email dan password. Validasi: format email, password wajib. Tautan Forgot
/// password dan Sign up. Akun belum terverifikasi diarahkan ke layar
/// Verifikasi email.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final destination = await ref.read(authControllerProvider.notifier).signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
    if (!mounted) return;

    if (destination == null) {
      final error = ref.read(authControllerProvider).error;
      final message = error == null
          ? 'Log in gagal. Coba lagi.'
          : AppException.from(error).message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }

    final path = switch (destination) {
      PostLoginDestination.verifyEmail => AppRoutes.emailVerification.path,
      PostLoginDestination.setupProfile => AppRoutes.setupProfile.path,
      PostLoginDestination.greeting => AppRoutes.greeting.path,
    };
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AuthMascot(assetPath: AppAssets.catLogin),
            const SizedBox(height: 8),
            const Text(
              'Log in to your account',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            AuthTextField(
              controller: _emailController,
              hint: 'Email',
              icon: Icons.mail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              enabled: !isLoading,
              validator: Validators.email,
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _passwordController,
              hint: 'Password',
              icon: Icons.lock,
              isPassword: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              enabled: !isLoading,
              validator: (value) =>
                  Validators.requiredField(value, fieldName: 'Password'),
              onSubmitted: (_) => _submit(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: AuthLink(
                label: 'Forgot password?',
                onPressed: isLoading
                    ? null
                    : () => context.push(AppRoutes.forgotPassword.path),
              ),
            ),
            const SizedBox(height: 12),
            AuthButton(
              label: 'Continue',
              isLoading: isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 16),
            Center(
              child: AuthLink(
                label: "Don't have an account? Sign up",
                onPressed: isLoading
                    ? null
                    : () => context.push(AppRoutes.signup.path),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
