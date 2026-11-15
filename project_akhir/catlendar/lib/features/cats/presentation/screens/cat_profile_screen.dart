import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/features/cats/presentation/providers/cat_providers.dart';
import 'package:catlendar/core/widgets/cat_avatar.dart';

class CatProfileScreen extends ConsumerWidget {
  const CatProfileScreen({super.key, required this.catId});

  final String catId;

  String _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age > 0 ? '$age years' : 'Kitten';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catAsync = ref.watch(catByIdProvider(catId));
    final medicalHistoryAsync = ref.watch(medicalHistoryByCatProvider(catId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cat Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: catAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (cat) {
          if (cat == null) {
            return const Center(child: Text('Data kucing tidak ditemukan.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Menggunakan CatAvatar agar tidak crash saat avatarId = 'cat_1'
                CatAvatar(avatarId: cat.avatarId, radius: 60),
                const SizedBox(height: 16),

                Text(
                  cat.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  '${_calculateAge(cat.dateOfBirth)} · ${cat.breed} · ${cat.color ?? 'Unknown'} · ${cat.gender} ${cat.neuterStatus}',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                TextButton.icon(
                  onPressed: () => context.push(
                    AppRoutes.editCat.location(
                      pathParameters: {AppRoutes.catIdParam: catId},
                    ),
                  ),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit Profile'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(),
                ),

                // Bagian Medical History
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Medical History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => context.push(
                        AppRoutes.editCat.location(
                          pathParameters: {AppRoutes.catIdParam: catId},
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Menampilkan daftar riwayat medis asli
                Align(
                  alignment: Alignment.centerLeft,
                  child: medicalHistoryAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (e, st) => const Text('Gagal memuat riwayat medis'),
                    data: (histories) {
                      if (histories.isEmpty) {
                        return const Text(
                          'Tidak ada riwayat medis.',
                          style: TextStyle(color: Colors.grey),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: histories.map((h) {
                          final text = (h.notes != null && h.notes!.isNotEmpty)
                              ? '• ${h.conditionName} — ${h.notes}'
                              : '• ${h.conditionName}';
                          return Text(
                            text,
                            style: const TextStyle(fontSize: 15, height: 1.5),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.calendar_month,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    'Calendar',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(
                    AppRoutes.calendar.location(
                      queryParameters: {AppRoutes.catIdQuery: catId},
                    ),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.summarize_outlined,
                    color: Colors.blueAccent,
                  ),
                  title: const Text(
                    'Summary',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(
                    AppRoutes.summary.location(
                      queryParameters: {AppRoutes.catIdQuery: catId},
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => context.push(
                      AppRoutes.scheduleSetup.location(
                        pathParameters: {AppRoutes.catIdParam: catId},
                      ),
                    ),
                    child: const Text(
                      '+ Set a Schedule',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
