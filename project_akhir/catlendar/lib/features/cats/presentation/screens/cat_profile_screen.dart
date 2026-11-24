import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/core/utils/date_utils.dart';
import 'package:catlendar/core/widgets/cat_avatar.dart';
import 'package:catlendar/features/care/presentation/providers/care_providers.dart';
import 'package:catlendar/features/care/presentation/utils/care_labels.dart';
import 'package:catlendar/features/care/presentation/utils/summary_builder.dart';
import 'package:catlendar/features/care/presentation/widgets/care_summary_list.dart';
import 'package:catlendar/features/cats/presentation/providers/cat_providers.dart';

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
    final schedulesAsync = ref.watch(schedulesByCatProvider(catId));
    final careRecordsAsync = ref.watch(careRecordsByCatProvider(catId));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: const Color(0xFF111111),
      ),
      body: catAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (cat) {
          if (cat == null) {
            return const Center(
              child: Text('The cat profile could not be found.'),
            );
          }

          final scheduleList = schedulesAsync.value ?? const [];
          final recordList = careRecordsAsync.value ?? const [];
          final summaryEntries = buildSummaryEntries(
            schedules: scheduleList,
            records: recordList,
            cats: [cat],
            catId: catId,
          );
          final upcomingSchedules = scheduleList
              .where((s) => s.isActive)
              .toList()
            ..sort((a, b) => a.nextDate.compareTo(b.nextDate));
          final careHistory = [...recordList]
            ..sort((a, b) => b.performedDate.compareTo(a.performedDate));

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CatAvatar(
                    avatarId: cat.avatarId,
                    catColor: cat.color,
                    radius: 56,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    cat.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_calculateAge(cat.dateOfBirth)} · ${cat.breed} · ${cat.color ?? 'Unknown'} · ${cat.gender} ${cat.neuterStatus}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B6B6B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => context.push(
                      AppRoutes.editCat.location(
                        pathParameters: {AppRoutes.catIdParam: catId},
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text(
                      'Edit profile',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF111111),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(color: Color(0xFFE5E5EA)),
                  ),

                  // 1. Medical History
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Medical History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111111),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Color(0xFF111111),
                        ),
                        onPressed: () => context.push(
                          AppRoutes.editCat.location(
                            pathParameters: {AppRoutes.catIdParam: catId},
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: medicalHistoryAsync.when(
                      loading: () => const CircularProgressIndicator(),
                      error: (e, st) =>
                          const Text('Failed to load medical history.'),
                      data: (histories) {
                        if (histories.isEmpty) {
                          return const Text(
                            'No saved medical history available.',
                            style: TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 13,
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: histories.map((h) {
                            final text = (h.notes != null && h.notes!.isNotEmpty)
                                ? '• ${h.conditionName} — ${h.notes}'
                                : '• ${h.conditionName}';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                text,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: Color(0xFF111111),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(color: Color(0xFFE5E5EA)),
                  ),

                  // 2. Upcoming Schedules
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Upcoming Schedules',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111111),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Set a Schedule',
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Color(0xFF111111),
                        ),
                        onPressed: () => context.push(
                          AppRoutes.scheduleSetup.location(
                            pathParameters: {AppRoutes.catIdParam: catId},
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: schedulesAsync.isLoading
                        ? const CircularProgressIndicator()
                        : upcomingSchedules.isEmpty
                            ? const Text(
                                'No upcoming care schedules.',
                                style: TextStyle(
                                  color: Color(0xFF8E8E93),
                                  fontSize: 13,
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (final schedule in upcomingSchedules)
                                    _ProfileScheduleTile(
                                      label: careTypeLabel(
                                        schedule.careType,
                                        customName: schedule.customName,
                                      ),
                                      date: schedule.nextDate,
                                      isOverdue: AppDateUtils.isBeforeDay(
                                        schedule.nextDate,
                                        AppDateUtils.dateOnly(DateTime.now()),
                                      ),
                                      onTap: () {
                                        final matching = summaryEntries
                                            .where((e) =>
                                                e.schedule?.scheduleId ==
                                                schedule.scheduleId)
                                            .toList();
                                        if (matching.isNotEmpty &&
                                            matching.first.overdue) {
                                          showOverdueScheduleCard(
                                            context: context,
                                            ref: ref,
                                            overdueEntry: matching.first,
                                            allEntries: summaryEntries,
                                          );
                                        } else {
                                          context.push(
                                            AppRoutes.scheduleSetup.location(
                                              pathParameters: {
                                                AppRoutes.catIdParam: catId,
                                              },
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                ],
                              ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(color: Color(0xFFE5E5EA)),
                  ),

                  // 3. Care History (Initial grooming info + completed schedules)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Care History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111111),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Add Care History',
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Color(0xFF111111),
                        ),
                        onPressed: () => context.push(
                          AppRoutes.groomingHistory.location(
                            pathParameters: {AppRoutes.catIdParam: catId},
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: careRecordsAsync.isLoading
                        ? const CircularProgressIndicator()
                        : careHistory.isEmpty
                            ? const Text(
                                'No care history recorded yet.',
                                style: TextStyle(
                                  color: Color(0xFF8E8E93),
                                  fontSize: 13,
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (final record in careHistory)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Icon(
                                            careTypeIcon(record.careType),
                                            size: 18,
                                            color: const Color(0xFF111111),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              careTypeLabel(
                                                record.careType,
                                                customName: record.customName,
                                              ),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF111111),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            AppDateUtils.formatDate(
                                              record.performedDate,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF6B6B6B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                  ),

                  const SizedBox(height: 28),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD0D0D0)),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      leading: const Icon(
                        Icons.calendar_month_outlined,
                        color: Color(0xFF111111),
                      ),
                      title: const Text(
                        'Calendar',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF111111),
                      ),
                      onTap: () => context.push(
                        AppRoutes.calendar.location(
                          queryParameters: {AppRoutes.catIdQuery: catId},
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD0D0D0)),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      leading: const Icon(
                        Icons.summarize_outlined,
                        color: Color(0xFF111111),
                      ),
                      title: const Text(
                        'Summary',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF111111),
                      ),
                      onTap: () => context.push(
                        AppRoutes.summary.location(
                          queryParameters: {AppRoutes.catIdQuery: catId},
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF111111),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () => context.push(
                      AppRoutes.scheduleSetup.location(
                        pathParameters: {AppRoutes.catIdParam: catId},
                      ),
                    ),
                    child: const Text(
                      '+ Set a Schedule',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileScheduleTile extends StatelessWidget {
  const _ProfileScheduleTile({
    required this.label,
    required this.date,
    required this.isOverdue,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final bool isOverdue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isOverdue ? const Color(0xFFFFEBEE) : const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOverdue ? const Color(0xFFE53935) : const Color(0xFFE5E5EA),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isOverdue ? Icons.warning_amber_rounded : Icons.event_available_outlined,
                size: 18,
                color: isOverdue ? const Color(0xFFD32F2F) : const Color(0xFF111111),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Next ${label.toLowerCase()}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isOverdue ? const Color(0xFFB71C1C) : const Color(0xFF111111),
                  ),
                ),
              ),
              Text(
                isOverdue ? 'Overdue • ${AppDateUtils.formatDate(date)}' : AppDateUtils.formatDate(date),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w500,
                  color: isOverdue ? const Color(0xFFD32F2F) : const Color(0xFF6B6B6B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
