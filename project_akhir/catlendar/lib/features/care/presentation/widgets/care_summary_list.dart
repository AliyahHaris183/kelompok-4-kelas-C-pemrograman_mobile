import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/core/utils/date_utils.dart';
import 'package:catlendar/core/widgets/cat_avatar.dart';
import 'package:catlendar/features/care/data/models/holiday.dart';
import 'package:catlendar/features/care/data/models/schedule.dart';
import 'package:catlendar/features/care/presentation/providers/care_providers.dart';
import 'package:catlendar/features/care/presentation/theme/care_theme.dart';
import 'package:catlendar/features/care/presentation/utils/summary_builder.dart';

/// Actions available on a Next schedule entry.
enum ScheduleAction { edit, complete, cancel, delete }

/// Runs a schedule action and shows a snackbar if it fails.
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
        title: const Text('Delete schedule?'),
        content: const Text('This schedule and its reminder will be deleted. Past history will remain.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
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

/// Shows a red bottom-sheet card when an overdue schedule is tapped,
/// displaying overdue details, summary, upcoming schedules, and care history.
void showOverdueScheduleCard({
  required BuildContext context,
  required WidgetRef ref,
  required SummaryEntry overdueEntry,
  required List<SummaryEntry> allEntries,
}) {
  final today = AppDateUtils.dateOnly(DateTime.now());
  final daysLate = today.difference(AppDateUtils.dateOnly(overdueEntry.date)).inDays;

  final catEntries = allEntries.where((e) => e.catId == overdueEntry.catId).toList();
  final overdueList =
      catEntries.where((e) => e.kind == SummaryKind.next && e.overdue).toList();
  final upcomingList =
      catEntries.where((e) => e.kind == SummaryKind.next && !e.overdue).toList();
  final historyList =
      catEntries.where((e) => e.kind == SummaryKind.last).toList().reversed.toList();

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) {
      return SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFD32F2F), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33B71C1C),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD32F2F),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Overdue Schedule',
                            style: TextStyle(
                              color: Color(0xFFB71C1C),
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '${overdueEntry.catName} • Overdue by ${daysLate <= 0 ? 1 : daysLate} day(s)',
                            style: const TextStyle(
                              color: Color(0xFFC62828),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetCtx).pop(),
                      icon: const Icon(Icons.close, color: Color(0xFFB71C1C)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MISSED SCHEDULE',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Next ${overdueEntry.label.toLowerCase()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Target date: ${AppDateUtils.formatDate(overdueEntry.date)}',
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      if (overdueList.length > 1) ...[
                        const SizedBox(height: 6),
                        Text(
                          '+ ${overdueList.length - 1} other overdue schedule(s) for ${overdueEntry.catName}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _RedSectionBox(
                  title: 'Summary (${overdueEntry.catName})',
                  child: Text(
                    '${overdueList.length} overdue • ${upcomingList.length} upcoming • ${historyList.length} completed',
                    style: const TextStyle(
                      color: Color(0xFF7F0000),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _RedSectionBox(
                  title: 'Upcoming Schedules',
                  child: upcomingList.isEmpty
                      ? const Text(
                          'No upcoming schedules.',
                          style: TextStyle(color: Color(0xFF8E0000), fontSize: 13),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final item in upcomingList.take(3))
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '• Next ${item.label.toLowerCase()} — ${AppDateUtils.formatDate(item.date)}',
                                  style: const TextStyle(
                                    color: Color(0xFF7F0000),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: 10),
                _RedSectionBox(
                  title: 'Recent Care History',
                  child: historyList.isEmpty
                      ? const Text(
                          'No care history recorded yet.',
                          style: TextStyle(color: Color(0xFF8E0000), fontSize: 13),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final item in historyList.take(3))
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '• Last ${item.label.toLowerCase()} — ${AppDateUtils.formatDate(item.date)}',
                                  style: const TextStyle(
                                    color: Color(0xFF7F0000),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
                if (overdueEntry.schedule != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFB71C1C),
                            side: const BorderSide(color: Color(0xFFD32F2F)),
                          ),
                          onPressed: () {
                            Navigator.of(sheetCtx).pop();
                            runScheduleAction(
                              context,
                              ref,
                              overdueEntry.schedule!,
                              ScheduleAction.edit,
                            );
                          },
                          child: const Text('Reschedule'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFD32F2F),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.of(sheetCtx).pop();
                            runScheduleAction(
                              context,
                              ref,
                              overdueEntry.schedule!,
                              ScheduleAction.complete,
                            );
                          },
                          child: const Text('Mark Complete'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _RedSectionBox extends StatelessWidget {
  const _RedSectionBox({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEF9A9A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFB71C1C),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

/// Summary entries grouped by date with public holiday markers.
class CareSummaryList extends ConsumerWidget {
  const CareSummaryList({
    super.key,
    required this.entries,
    this.contextEntries,
    this.emptyText = 'No activities recorded.',
  });

  final List<SummaryEntry> entries;
  final List<SummaryEntry>? contextEntries;
  final String emptyText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            emptyText,
            style: const TextStyle(color: CareTheme.muted),
          ),
        ),
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
    final allContext = contextEntries ?? entries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final group in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppDateUtils.formatDate(group.key),
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (holidayByIso[AppDateUtils.toIsoDate(group.key)] case final holiday?)
                  Text(
                    'Holiday: ${holiday.name}',
                    style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
                  ),
              ],
            ),
          ),
          for (final entry in group.value)
            _SummaryTile(
              entry: entry,
              onTapOverdue: entry.overdue
                  ? () => showOverdueScheduleCard(
                        context: context,
                        ref: ref,
                        overdueEntry: entry,
                        allEntries: allContext,
                      )
                  : null,
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
  const _SummaryTile({
    required this.entry,
    this.onTapOverdue,
    this.onAction,
  });

  final SummaryEntry entry;
  final VoidCallback? onTapOverdue;
  final void Function(ScheduleAction action)? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNext = entry.kind == SummaryKind.next;
    final isOverdue = entry.overdue;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: isOverdue
          ? BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE53935)),
            )
          : null,
      child: ListTile(
        onTap: isOverdue ? onTapOverdue : null,
        leading: CatAvatar(
          avatarId: entry.avatarId,
          catColor: entry.catColor,
          radius: 22,
          fallbackName: entry.catName,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        title: Text(
          '${isNext ? 'Next' : 'Last'} ${entry.label.toLowerCase()}',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: isOverdue ? const Color(0xFFB71C1C) : null,
          ),
        ),
        subtitle: Text(
          isOverdue ? '${entry.catName} • Tap for overdue details' : entry.catName,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isOverdue ? const Color(0xFFC62828) : CareTheme.muted,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOverdue)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Chip(
                  label: const Text(
                    'Overdue',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: const Color(0xFFD32F2F),
                ),
              ),
            if (onAction != null)
              PopupMenuButton<ScheduleAction>(
                tooltip: 'Schedule actions',
                onSelected: onAction,
                itemBuilder: (_) => const [
                  PopupMenuItem(value: ScheduleAction.edit, child: Text('Edit schedule')),
                  PopupMenuItem(value: ScheduleAction.complete, child: Text('Mark complete')),
                  PopupMenuItem(value: ScheduleAction.cancel, child: Text('Cancel schedule')),
                  PopupMenuItem(value: ScheduleAction.delete, child: Text('Delete schedule')),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
