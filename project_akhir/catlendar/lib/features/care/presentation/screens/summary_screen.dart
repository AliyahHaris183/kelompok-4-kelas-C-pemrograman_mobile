import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/features/care/presentation/providers/care_providers.dart';
import 'package:catlendar/features/care/presentation/theme/care_theme.dart';
import 'package:catlendar/features/care/presentation/utils/summary_builder.dart';
import 'package:catlendar/features/care/presentation/widgets/care_summary_list.dart';
import 'package:catlendar/features/cats/presentation/providers/cat_providers.dart';

/// Layar 20: Summary.
class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key, this.catId});

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
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Kembali',
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.home.path);
              }
            },
          ),
          title: const Text('Summary'),
        ),
        body: SafeArea(child: body),
      ),
    );
  }
}
