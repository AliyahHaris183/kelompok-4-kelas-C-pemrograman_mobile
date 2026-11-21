import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/features/care/presentation/providers/care_providers.dart';
import 'package:catlendar/features/care/presentation/theme/care_theme.dart';
import 'package:catlendar/features/care/presentation/utils/summary_builder.dart';
import 'package:catlendar/features/care/presentation/widgets/care_summary_list.dart';
import 'package:catlendar/features/cats/presentation/providers/cat_providers.dart';

/// Layar 20: Summary.
///
/// Dikelompokkan per tanggal. Setiap entri: jenis perawatan dengan label Last
/// (riwayat, CARE_RECORD) atau Next (jadwal, SCHEDULE), avatar dan nama kucing,
/// serta tanggal. catId opsional: jika ada, hanya tampilkan kucing tersebut.
class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key, this.catId});

  /// Opsional.
  final String? catId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedules = ref.watch(schedulesByOwnerProvider);
    final records = ref.watch(careRecordsByOwnerProvider);
    final cats = ref.watch(userCatsProvider);

    final Widget body;
    if (schedules.hasError || records.hasError || cats.hasError) {
      body = const Center(child: Text('Summary belum bisa dimuat.'));
    } else if (schedules.value == null || records.value == null || cats.value == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      final entries = buildSummaryEntries(
        schedules: schedules.value!,
        records: records.value!,
        cats: cats.value!,
        catId: catId,
      );
      body = ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          CareSummaryList(entries: entries),
        ],
      );
    }

    return Theme(
      data: CareTheme.of(context),
      child: Scaffold(
        appBar: AppBar(title: const Text('Summary')),
        body: SafeArea(child: body),
      ),
    );
  }
}
