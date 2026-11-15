import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/core/utils/validators.dart';
import 'package:catlendar/features/auth/presentation/providers/profile_providers.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_button.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_link.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_mascot.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_text_field.dart';

/// Layar 5: Sign up. Hanya email; password dibuat di layar berikutnya.
///
/// Pengecekan "email belum terdaftar" terjadi di layar Create password, saat
/// akun dibuat (Firebase menolak dengan email-already-in-use).
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = ref.read(signUpEmailProvider);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    ref.read(signUpEmailProvider.notifier).setEmail(_emailController.text);
    context.push(AppRoutes.createPassword.path);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AuthMascot(assetPath: 'assets/images/cat_signup.png'),
            const SizedBox(height: 8),
            const Text(
              'Sign up',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            AuthTextField(
              controller: _emailController,
              hint: 'Email',
              icon: Icons.mail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            AuthButton(label: 'Continue', onPressed: _submit),
            const SizedBox(height: 16),
            Center(
              child: AuthLink(
                label: 'Already have an account? Log in',
                onPressed: () => context.go(AppRoutes.login.path),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
