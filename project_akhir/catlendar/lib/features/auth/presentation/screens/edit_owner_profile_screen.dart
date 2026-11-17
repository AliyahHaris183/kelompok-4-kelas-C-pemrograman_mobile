import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/core/constants/app_assets.dart';
import 'package:catlendar/core/constants/avatar_presets.dart';
import 'package:catlendar/core/constants/gender_options.dart';
import 'package:catlendar/core/errors/app_exception.dart';
import 'package:catlendar/core/utils/date_utils.dart';
import 'package:catlendar/core/utils/validators.dart';
import 'package:catlendar/core/widgets/async_value_view.dart';
import 'package:catlendar/core/widgets/empty_view.dart';
import 'package:catlendar/features/auth/data/models/app_user.dart';
import 'package:catlendar/features/auth/presentation/providers/auth_providers.dart';
import 'package:catlendar/features/auth/presentation/providers/profile_controller.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_button.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_mascot.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_option_selector.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:catlendar/shared/widgets/avatar_selector.dart';
import 'package:catlendar/shared/widgets/confirm_dialog.dart';

/// Layar 22: Edit profile (pemilik). Form sama dengan Set up profile, sudah
/// terisi. Validasi sama. Ringkasan ditampilkan sebagai dialog konfirmasi
/// sebelum simpan, lalu USERS diperbarui (updated_at diisi).
///
/// Tanggal lahir memakai pemilih tanggal bawaan, bukan layar Date of birth,
/// karena rute onboarding tidak boleh dibuka oleh akun yang sudah lengkap
/// (lihat route_guard.dart).
class EditOwnerProfileScreen extends ConsumerWidget {
  const EditOwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider);

    return AuthScaffold(
      showBack: true,
      child: AsyncValueView<AppUser?>(
        value: profile,
        builder: (user) {
          if (user == null) {
            return const EmptyView(message: 'Profil tidak ditemukan');
          }
          return _EditProfileForm(user: user);
        },
      ),
    );
  }
}

class _EditProfileForm extends ConsumerStatefulWidget {
  const _EditProfileForm({required this.user});

  final AppUser user;

  @override
  ConsumerState<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends ConsumerState<_EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dobController;
  late DateTime _dateOfBirth;
  String? _gender;
  String? _avatarId;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _nameController = TextEditingController(text: user.name);
    _dateOfBirth = user.dateOfBirth;
    _dobController = TextEditingController(
      text: AppDateUtils.formatDate(user.dateOfBirth),
    );
    _gender = user.gender;
    _avatarId = user.avatarId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth,
      firstDate: DateTime(1900),
      lastDate: AppDateUtils.dateOnly(DateTime.now()),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _dateOfBirth = AppDateUtils.dateOnly(picked);
      _dobController.text = AppDateUtils.formatDate(_dateOfBirth);
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Save changes?',
      message: 'Name: $name\n'
          'Date of birth: ${AppDateUtils.formatDate(_dateOfBirth)}\n'
          'Gender: ${_gender ?? '-'}\n\n'
          'Please double-check your details before saving.',
      confirmLabel: 'Save',
      cancelLabel: 'Back',
    );
    if (!confirmed || !mounted) return;

    final ok = await ref.read(profileControllerProvider.notifier).updateProfile(
          name: name,
          dateOfBirth: _dateOfBirth,
          gender: _gender,
          avatarId: _avatarId,
        );
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    if (!ok) {
      final error = ref.read(profileControllerProvider).error;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error == null
                ? 'Gagal menyimpan profil. Coba lagi.'
                : AppException.from(error).message,
          ),
        ),
      );
      return;
    }

    messenger.showSnackBar(const SnackBar(content: Text('Profile updated.')));
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(profileControllerProvider).isLoading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthMascot(assetPath: AppAssets.catSignup),
          const SizedBox(height: 8),
          const Text(
            'Edit profile',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          AvatarSelector(
            avatarIds: AvatarPresets.ownerAvatarIds,
            selectedId: _avatarId,
            onChanged: (id) => setState(() => _avatarId = id),
            size: 48,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _nameController,
            hint: 'Name',
            icon: Icons.person,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            enabled: !isSaving,
            validator: (value) =>
                Validators.requiredField(value, fieldName: 'Nama'),
          ),
          const SizedBox(height: 12),
          AuthTextField(
            controller: _dobController,
            hint: 'Date of birth',
            icon: Icons.calendar_today,
            readOnly: true,
            enabled: !isSaving,
            onTap: _pickDate,
            validator: (value) =>
                Validators.requiredField(value, fieldName: 'Tanggal lahir'),
          ),
          const SizedBox(height: 16),
          const Text('Gender', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          AuthOptionSelector(
            options: GenderOptions.values,
            selected: _gender,
            onChanged: (value) => setState(() => _gender = value),
          ),
          const SizedBox(height: 24),
          AuthButton(label: 'Save', isLoading: isSaving, onPressed: _save),
        ],
      ),
    );
  }
}
