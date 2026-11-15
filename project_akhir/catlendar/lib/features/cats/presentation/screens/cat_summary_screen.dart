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

    ref.listen<AsyncValue<void>>(catEditorControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $error')));
        },
        data: (_) {
          if (previous?.isLoading == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data kucing berhasil disimpan!')),
            );
            context.goNamed(AppRoutes.home.name);
          }
        },
      );
    });

    if (catDraft == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Summary')),
        body: const Center(
          child: Text('Tidak ada data draf untuk ditampilkan.'),
        ),
      );
    }

    final isSaving = editorState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 48, color: Colors.blueAccent),
            const SizedBox(height: 16),
            const Text(
              'Please review your cat\'s profile\nbefore saving.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    CatAvatar(
                      avatarId: catDraft.avatarId,
                      catColor: catDraft.color,
                      radius: 40,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      catDraft.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 32),
                    _buildInfoRow('Breed', catDraft.breed),
                    _buildInfoRow('Gender', catDraft.gender),
                    _buildInfoRow('Neuter Status', catDraft.neuterStatus),
                    _buildInfoRow('Color', catDraft.color ?? '-'),
                    _buildInfoRow(
                      'Date of Birth',
                      '${catDraft.dateOfBirth.day}/${catDraft.dateOfBirth.month}/${catDraft.dateOfBirth.year}',
                    ),
                    if (historyDrafts.isNotEmpty) ...[
                      const Divider(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Medical History',
                          style: TextStyle(color: Colors.black54, fontSize: 14),
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
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'By saving, you confirm that the data provided is correct. You can edit this later in the cat profile settings.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.black),
                    ),
                    onPressed: isSaving ? null : () => context.pop(),
                    child: const Text(
                      'Back',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: isSaving
                        ? null
                        : () {
                            final isEdit = catDraft.updatedAt.isAfter(
                              catDraft.createdAt,
                            );
                            ref
                                .read(catEditorControllerProvider.notifier)
                                .saveCatWithHistory(
                                  cat: catDraft,
                                  histories: historyDrafts,
                                  isEdit: isEdit,
                                );
                          },
                    child: isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
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
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
