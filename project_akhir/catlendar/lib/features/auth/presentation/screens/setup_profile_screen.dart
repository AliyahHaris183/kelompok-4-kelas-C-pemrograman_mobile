import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/core/constants/app_assets.dart';
import 'package:catlendar/core/constants/gender_options.dart';
import 'package:catlendar/core/errors/app_exception.dart';
import 'package:catlendar/core/utils/date_utils.dart';
import 'package:catlendar/core/utils/validators.dart';
import 'package:catlendar/features/auth/presentation/providers/profile_photo_controller.dart';
import 'package:catlendar/features/auth/presentation/providers/profile_providers.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_button.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_mascot.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_option_selector.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:catlendar/features/auth/presentation/widgets/profile_photo_picker.dart';

/// Layar 9: Set up your profile.
/// Foto profil (galeri atau avatar preset), Name, Date of birth (dipilih di
/// layar 10), Gender. Validasi: nama dan tanggal lahir wajib. Belum menulis ke
/// Firestore; foto diunggah ke Cloudinary saat dipilih, dan URL-nya disimpan
/// di draft sampai tombol Save di layar Ringkasan.
class SetupProfileScreen extends ConsumerStatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  ConsumerState<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends ConsumerState<SetupProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();

  static String _formatDob(DateTime? date) =>
      date == null ? '' : AppDateUtils.formatDate(date);

  @override
  void initState() {
    super.initState();
    final draft = ref.read(profileDraftProvider);
    _nameController.text = draft.name;
    _dobController.text = _formatDob(draft.dateOfBirth);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final url =
        await ref.read(profilePhotoControllerProvider.notifier).pickAndUpload();
    if (!mounted) return;

    if (url != null) {
      ref.read(profileDraftProvider.notifier).setAvatar(url);
      return;
    }
    // Null tanpa error berarti pengguna membatalkan pilihan.
    final error = ref.read(profilePhotoControllerProvider).error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppException.from(error).message)),
      );
    }
  }

  void _continue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    ref.read(profileDraftProvider.notifier).setName(_nameController.text);
    context.push(AppRoutes.profileSummary.path);
  }

  void _pickDate() {
    FocusScope.of(context).unfocus();
    context.push(AppRoutes.dateOfBirth.path);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(profileDraftProvider);
    final isUploading = ref.watch(profilePhotoControllerProvider).isLoading;

    // Sinkronkan teks tanggal saat layar Date of birth mengubah draft.
    ref.listen<ProfileDraft>(profileDraftProvider, (previous, next) {
      _dobController.text = _formatDob(next.dateOfBirth);
    });

    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AuthMascot(assetPath: AppAssets.catSetupSettings),
            const SizedBox(height: 8),
            const Text(
              'Set up your profile',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            Center(
              child: ProfilePhotoPicker(
                avatarId: draft.avatarId,
                isUploading: isUploading,
                onChooseFromGallery: _pickPhoto,
                onChoosePreset: ref.read(profileDraftProvider.notifier).setAvatar,
              ),
            ),
            const SizedBox(height: 20),
            AuthTextField(
              controller: _nameController,
              hint: 'Name',
              icon: Icons.person,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.givenName],
              validator: (value) =>
                  Validators.requiredField(value, fieldName: 'Nama'),
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _dobController,
              hint: 'Date of birth',
              icon: Icons.calendar_today,
              readOnly: true,
              onTap: _pickDate,
              validator: (value) =>
                  Validators.requiredField(value, fieldName: 'Tanggal lahir'),
            ),
            const SizedBox(height: 16),
            const Text('Gender', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            AuthOptionSelector(
              options: GenderOptions.values,
              selected: draft.gender,
              onChanged: ref.read(profileDraftProvider.notifier).setGender,
            ),
            const SizedBox(height: 24),
            AuthButton(
              label: 'Continue',
              // Tunggu unggah selesai agar URL foto ikut tersimpan di draft.
              onPressed: isUploading ? null : _continue,
            ),
          ],
        ),
      ),
    );
  }
}
