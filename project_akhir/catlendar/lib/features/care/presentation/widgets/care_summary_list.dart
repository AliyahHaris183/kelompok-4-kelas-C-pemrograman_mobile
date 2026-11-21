import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';

import 'package:catlendar/core/utils/date_utils.dart';
import 'package:catlendar/core/widgets/cat_avatar.dart';
import 'package:catlendar/features/care/data/models/holiday.dart';
import 'package:catlendar/features/care/data/models/schedule.dart';
import 'package:catlendar/features/care/presentation/providers/care_providers.dart';
import 'package:catlendar/features/care/presentation/utils/summary_builder.dart';
import 'package:catlendar/features/care/presentation/theme/care_theme.dart';

/// Aksi pada jadwal Next.
enum ScheduleAction { edit, complete, cancel, delete }

/// Menjalankan aksi jadwal dan menampilkan pesan bila gagal.
Future<void> runScheduleAction(
  BuildContext context,
  WidgetRef ref,
  Schedule schedule,
  ScheduleAction action,
) async {
  if (action == ScheduleAction.edit) {
    context.push(
      AppRoutes.scheduleSetup.location(pathParameters: {AppRoutes.catIdParam: schedule.catId}),
    );
    return;
  }

  if (action == ScheduleAction.delete) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus jadwal?'),
        content: const Text('Jadwal dan pengingatnya akan dihapus. Riwayat tidak ikut terhapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
  }

  final controller = ref.read(careActionControllerProvider.notifier);
  String? error;
  if (action == ScheduleAction.complete) {
    error = await controller.completeSchedule(schedule);
  } else if (action == ScheduleAction.cancel) {
    error = await controller.cancelSchedule(schedule);
  } else {
    error = await controller.deleteSchedule(schedule);
  }

  if (!context.mounted) return;
  if (error != null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }
}

/// Daftar entri Summary dikelompokkan per tanggal, dengan penanda hari libur (FR-61).
class CareSummaryList extends ConsumerWidget {
  const CareSummaryList({
    super.key,
    required this.entries,
    this.emptyText = 'Belum ada aktivitas.',
  });

  final List<SummaryEntry> entries;
  final String emptyText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text(emptyText)),
      );
    }

    final holidayByIso = <String, Holiday>{};
    final years = {for (final entry in entries) entry.date.year};
    for (final year in years) {
      final holidays = ref.watch(holidaysProvider(year)).value ?? const <Holiday>[];
      for (final holiday in holidays) {
        holidayByIso[AppDateUtils.toIsoDate(holiday.date)] = holiday;
      }
    }

    final groups = <DateTime, List<SummaryEntry>>{};
    for (final entry in entries) {
      groups.putIfAbsent(entry.date, () => []).add(entry);
    }

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final group in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppDateUtils.formatDate(group.key),
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (holidayByIso[AppDateUtils.toIsoDate(group.key)] case final holiday?)
                  Text(
                    'Hari libur: ${holiday.name}',
                    style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
                  ),
              ],
            ),
          ),
          for (final entry in group.value)
            _SummaryTile(
              entry: entry,
              onAction: entry.schedule == null
                  ? null
                  : (action) => runScheduleAction(context, ref, entry.schedule!, action),
            ),
        ],
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.entry, this.onAction});

  final SummaryEntry entry;
  final void Function(ScheduleAction action)? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNext = entry.kind == SummaryKind.next;
    return ListTile(
      onTap: onAction == null ? null : () => onAction!(ScheduleAction.edit),
      leading: CatAvatar(
        avatarId: entry.avatarId,
        radius: 22,
        fallbackName: entry.catName,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        '${isNext ? 'Next' : 'Last'} ${entry.label.toLowerCase()}',
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        entry.catName,
        style: theme.textTheme.bodySmall?.copyWith(color: CareTheme.muted),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (entry.overdue)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Chip(
                label: const Text('Terlewat'),
                visualDensity: VisualDensity.compact,
                backgroundColor: theme.colorScheme.errorContainer,
              ),
            ),
          if (onAction != null)
            PopupMenuButton<ScheduleAction>(
              tooltip: 'Aksi jadwal',
              onSelected: onAction,
              itemBuilder: (_) => const [
                PopupMenuItem(value: ScheduleAction.edit, child: Text('Ubah jadwal')),
                PopupMenuItem(value: ScheduleAction.complete, child: Text('Tandai selesai')),
                PopupMenuItem(value: ScheduleAction.cancel, child: Text('Batalkan jadwal')),
                PopupMenuItem(value: ScheduleAction.delete, child: Text('Hapus jadwal')),
              ],
            ),
        ],
      ),
    );
  }
}
