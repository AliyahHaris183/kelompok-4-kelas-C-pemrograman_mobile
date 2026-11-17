import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/core/errors/app_exception.dart';
import 'package:catlendar/core/utils/date_utils.dart';
import 'package:catlendar/features/auth/presentation/providers/profile_controller.dart';
import 'package:catlendar/features/auth/presentation/providers/profile_providers.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_button.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_scaffold.dart';

/// Layar 11: Ringkasan profil. Nama, tanggal lahir, gender, dan peringatan
/// sebelum simpan. Save membuat dokumen USERS dengan onboarding_done = true.
///
/// fcm_token disimpan otomatis oleh fcm_token_sync.dart setelah profil dibuat.
class ProfileSummaryScreen extends ConsumerWidget {
  const ProfileSummaryScreen({super.key});

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(profileControllerProvider.notifier).saveNewProfile();
    if (!context.mounted) return;

    if (!ok) {
      final error = ref.read(profileControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
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
    // Berikutnya: Add your first cat (layar 12, milik Orang 2).
    context.go(AppRoutes.addCat.path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(profileDraftProvider);
    final isLoading = ref.watch(profileControllerProvider).isLoading;
    final dateOfBirth = draft.dateOfBirth;

    return AuthScaffold(
      showBack: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your profile',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          // TODO(Orang 1): tampilkan avatar preset yang dipilih (draft.avatarId).
          const CircleAvatar(radius: 32, child: Icon(Icons.pets)),
          const SizedBox(height: 16),
          _SummaryRow(
            label: 'Name',
            value: draft.name.isEmpty ? '-' : draft.name,
          ),
          _SummaryRow(
            label: 'Date of birth',
            value: dateOfBirth == null
                ? '-'
                : AppDateUtils.formatDate(dateOfBirth),
          ),
          _SummaryRow(label: 'Gender', value: draft.gender ?? '-'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD0D0D0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Please double-check your details before saving.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AuthButton(
                  label: 'Back',
                  isOutlined: true,
                  onPressed: isLoading
                      ? null
                      : () {
                          if (context.canPop()) context.pop();
                        },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AuthButton(
                  label: 'Save',
                  isLoading: isLoading,
                  onPressed: () => _save(context, ref),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B6B6B)),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
