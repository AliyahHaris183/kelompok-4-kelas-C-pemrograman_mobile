import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/core/constants/app_assets.dart';
import 'package:catlendar/core/errors/app_exception.dart';
import 'package:catlendar/core/utils/validators.dart';
import 'package:catlendar/features/auth/presentation/providers/auth_controller.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_button.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_mascot.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_text_field.dart';

/// Layar 23: Change password. Password lama, password baru, konfirmasi.
/// Validasi sama dengan Create password. Reautentikasi lalu updatePassword.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateNewPassword(String? value) {
    final base = Validators.password(value);
    if (base != null) return base;
    if (value == _currentController.text) {
      return 'Password baru harus berbeda dari password lama';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final ok = await ref.read(authControllerProvider.notifier).changePassword(
          currentPassword: _currentController.text,
          newPassword: _newController.text,
        );
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    if (!ok) {
      final error = ref.read(authControllerProvider).error;
      final appError = error == null ? null : AppException.from(error);
      // Pada layar ini, kredensial salah berarti password lama yang salah.
      final wrongOldPassword = appError?.code == 'wrong-password' ||
          appError?.code == 'invalid-credential';
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            wrongOldPassword
                ? 'Password lama salah.'
                : appError?.message ?? 'Gagal mengubah password. Coba lagi.',
          ),
        ),
      );
      return;
    }

    messenger.showSnackBar(const SnackBar(content: Text('Password updated.')));
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
            const AuthMascot(assetPath: AppAssets.catSignup),
            const SizedBox(height: 8),
            const Text(
              'Change password',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            AuthTextField(
              controller: _currentController,
              hint: 'Current password',
              icon: Icons.lock,
              isPassword: true,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.password],
              enabled: !isLoading,
              validator: (value) => Validators.requiredField(
                value,
                fieldName: 'Password lama',
              ),
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _newController,
              hint: 'New password',
              icon: Icons.lock,
              isPassword: true,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              enabled: !isLoading,
              validator: _validateNewPassword,
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _confirmController,
              hint: 'Confirm new password',
              icon: Icons.lock,
              isPassword: true,
              textInputAction: TextInputAction.done,
              enabled: !isLoading,
              validator: (value) =>
                  Validators.confirmPassword(value, _newController.text),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            AuthButton(
              label: 'Save',
              isLoading: isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
