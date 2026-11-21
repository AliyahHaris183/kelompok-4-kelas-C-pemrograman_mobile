import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/features/cats/presentation/providers/cat_providers.dart';
import 'package:catlendar/core/widgets/cat_avatar.dart';

class CatSummaryScreen extends ConsumerWidget {
  const CatSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catDraft = ref.watch(catDraftProvider);
    final historyDrafts = ref.watch(medicalHistoryDraftProvider);
    final editorState = ref.watch(catEditorControllerProvider);
    // Kucing baru (belum ada di daftar) lanjut ke Riwayat perawatan (layar 17), lalu 18.
    final existingIds = (ref.watch(userCatsProvider).value ?? const [])
        .map((c) => c.catId)
        .toSet();
    final String? newCatId =
        catDraft != null && !existingIds.contains(catDraft.catId)
            ? catDraft.catId
            : null;

    ref.listen<AsyncValue<void>>(catEditorControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Failed to save: $error')));
        },
        data: (_) {
          if (previous?.isLoading == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cat data saved successfully!')),
            );
            if (newCatId != null) {
              context.go(
                AppRoutes.groomingHistory
                    .location(pathParameters: {AppRoutes.catIdParam: newCatId}),
              );
            } else {
              context.goNamed(AppRoutes.home.name);
            }
          }
        },
      );
    });

    if (catDraft == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Summary')),
        body: const Center(
          child: Text('No draft data available for display.'),
        ),
      );
    }

    final isSaving = editorState.isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: const Color(0xFF111111),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                  const Text(
                    'Summary',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please review your cat's profile before saving.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B6B6B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFD0D0D0)),
                    ),
                    child: Column(
                      children: [
                        CatAvatar(
                          avatarId: catDraft.avatarId,
                          catColor: catDraft.color,
                          radius: 44,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          catDraft.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111111),
                          ),
                        ),
                        const Divider(height: 28, color: Color(0xFFE5E5EA)),
                        _buildInfoRow('Breed', catDraft.breed),
                        _buildInfoRow('Gender', catDraft.gender),
                        _buildInfoRow('Neuter Status', catDraft.neuterStatus),
                        _buildInfoRow('Color', catDraft.color ?? '-'),
                        _buildInfoRow(
                          'Date of Birth',
                          '${catDraft.dateOfBirth.day}/${catDraft.dateOfBirth.month}/${catDraft.dateOfBirth.year}',
                        ),
                        if (historyDrafts.isNotEmpty) ...[
                          const Divider(height: 24, color: Color(0xFFE5E5EA)),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Medical History',
                              style: TextStyle(
                                color: Color(0xFF6B6B6B),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...historyDrafts.map(
                            (h) => Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Text(
                                  h.notes != null && h.notes!.isNotEmpty
                                      ? '• ${h.conditionName} (${h.notes})'
                                      : '• ${h.conditionName}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Color(0xFF111111),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'By saving, you confirm that the data provided is correct. You can edit this later in the cat profile settings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            shape: const StadiumBorder(),
                            side: const BorderSide(color: Color(0xFF111111)),
                            foregroundColor: const Color(0xFF111111),
                          ),
                          onPressed: isSaving ? null : () => context.pop(),
                          child: const Text('Back'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            shape: const StadiumBorder(),
                            backgroundColor: const Color(0xFF111111),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: isSaving
                              ? null
                              : () {
                                  final isEdit = catDraft.updatedAt.isAfter(
                                    catDraft.createdAt,
                                  );
                                  ref
                                      .read(
                                          catEditorControllerProvider.notifier)
                                      .saveCatWithHistory(
                                        cat: catDraft,
                                        histories: historyDrafts,
                                        isEdit: isEdit,
                                      );
                                },
                          child: isSaving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                          : const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF6B6B6B), fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF111111),
            ),
          ),
        ],
      ),
    );
  }
}
