import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/core/utils/date_utils.dart';
import 'package:catlendar/core/widgets/cat_avatar.dart';
import 'package:catlendar/features/auth/presentation/providers/auth_providers.dart';
import 'package:catlendar/features/care/data/models/holiday.dart';
import 'package:catlendar/features/care/presentation/providers/care_providers.dart';
import 'package:catlendar/features/care/presentation/theme/care_theme.dart';
import 'package:catlendar/features/care/presentation/utils/summary_builder.dart';
import 'package:catlendar/features/care/presentation/widgets/care_summary_list.dart';
import 'package:catlendar/features/cats/data/models/cat.dart';
import 'package:catlendar/features/cats/presentation/providers/cat_providers.dart';
import 'package:catlendar/shared/widgets/avatar_image.dart';

enum _HistoryPeriod {
  allTime('All Time'),
  last3Months('Last 3 Months'),
  last6Months('Last 6 Months'),
  lastYear('Last 1 Year');

  const _HistoryPeriod(this.label);
  final String label;
}

/// Screen 19: Monthly calendar with profile integration, Summary, and filterable Care History.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key, this.catId});

  final String? catId;

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  static const List<String> _weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selected;
  late String? _activeCatId = widget.catId;
  _HistoryPeriod _historyPeriod = _HistoryPeriod.allTime;

  @override
  void didUpdateWidget(covariant CalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.catId != widget.catId) {
      _activeCatId = widget.catId;
    }
  }

  void _shiftMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
      _selected = null;
    });
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home.path);
    }
  }

  List<SummaryEntry> _filterHistory(List<SummaryEntry> history) {
    if (_historyPeriod == _HistoryPeriod.allTime) return history;
    final now = AppDateUtils.dateOnly(DateTime.now());
    final DateTime cutoff = switch (_historyPeriod) {
      _HistoryPeriod.allTime => DateTime(1970),
      _HistoryPeriod.last3Months => DateTime(now.year, now.month - 3, now.day),
      _HistoryPeriod.last6Months => DateTime(now.year, now.month - 6, now.day),
      _HistoryPeriod.lastYear => DateTime(now.year - 1, now.month, now.day),
    };
    return history.where((e) => !e.date.isBefore(cutoff)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(data: CareTheme.of(context), child: _body(context));
  }

  Widget _body(BuildContext context) {
    final theme = Theme.of(context);
    final schedules = ref.watch(schedulesByOwnerProvider);
    final records = ref.watch(careRecordsByOwnerProvider);
    final cats = ref.watch(userCatsProvider);
    final userProfile = ref.watch(currentUserProfileProvider).value;
    final holidays = ref.watch(holidaysProvider(_month.year));

    if (schedules.hasError || records.hasError || cats.hasError) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _handleBack),
          title: const Text('Calendar'),
        ),
        body: const Center(child: Text('Unable to load calendar.')),
      );
    }
    final scheduleList = schedules.value;
    final recordList = records.value;
    final catList = cats.value;
    if (scheduleList == null || recordList == null || catList == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _handleBack),
          title: const Text('Calendar'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final catById = {for (final c in catList) c.catId: c};
    final effectiveCatId =
        (_activeCatId != null && catById.containsKey(_activeCatId)) ? _activeCatId : null;
    final selectedCat = effectiveCatId == null ? null : catById[effectiveCatId];

    final allEntries = buildSummaryEntries(
      schedules: scheduleList,
      records: recordList,
      cats: catList,
      catId: effectiveCatId,
    );
    final monthEntries = allEntries
        .where((e) => e.date.year == _month.year && e.date.month == _month.month)
        .toList();
    final byDay = <String, List<SummaryEntry>>{};
    for (final entry in monthEntries) {
      byDay.putIfAbsent(AppDateUtils.toIsoDate(entry.date), () => []).add(entry);
    }
    final holidayByIso = <String, Holiday>{
      for (final holiday in holidays.value ?? const <Holiday>[])
        AppDateUtils.toIsoDate(holiday.date): holiday,
    };

    final shownSummary = _selected == null
        ? monthEntries
        : monthEntries
            .where((e) => AppDateUtils.isSameDay(e.date, _selected!))
            .toList();

    final allHistoryEntries = allEntries
        .where((e) => e.kind == SummaryKind.last)
        .toList()
        .reversed
        .toList();
    final filteredHistory = _filterHistory(allHistoryEntries);

    final leading = DateTime(_month.year, _month.month, 1).weekday - 1;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final cellCount = ((leading + daysInMonth) / 7).ceil() * 7;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBack,
        ),
        title: Text(
          selectedCat == null ? 'Care Calendar' : "${selectedCat.name}'s Calendar",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Summary',
            icon: const Icon(Icons.list_alt_rounded),
            onPressed: () => context.push(
              AppRoutes.summary.location(
                queryParameters: effectiveCatId == null
                    ? null
                    : {AppRoutes.catIdQuery: effectiveCatId},
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'set_schedule_fab',
        onPressed: () => _openCatRoute(catList, isHistory: false),
        backgroundColor: CareTheme.ink,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        icon: const Icon(Icons.add),
        label: const Text('Set a Schedule'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: CareTheme.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AvatarImage(
                        avatarId: userProfile?.avatarId,
                        size: 40,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userProfile?.name ?? 'Cat Owner',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              selectedCat == null
                                  ? 'Showing all cats (${catList.length})'
                                  : 'Active profile: ${selectedCat.name}',
                              style: theme.textTheme.bodySmall?.copyWith(color: CareTheme.muted),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _openCatRoute(catList, isHistory: true),
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: const Text('Add History'),
                      ),
                    ],
                  ),
                  if (catList.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('All'),
                            selected: effectiveCatId == null,
                            onSelected: (_) => setState(() => _activeCatId = null),
                          ),
                          const SizedBox(width: 8),
                          for (final cat in catList) ...[
                            ChoiceChip(
                              avatar: CatAvatar(
                                avatarId: cat.avatarId,
                                catColor: cat.color,
                                radius: 10,
                                fallbackName: cat.name,
                              ),
                              label: Text(cat.name),
                              selected: effectiveCatId == cat.catId,
                              onSelected: (_) => setState(() => _activeCatId = cat.catId),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (holidays.hasError)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Public holiday data is currently unavailable. Calendar and schedules still work normally.',
                ),
              ),
            Row(
              children: [
                IconButton(
                  tooltip: 'Previous month',
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _shiftMonth(-1),
                ),
                Expanded(
                  child: Text(
                    AppDateUtils.formatMonthYear(_month),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: 'Next month',
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _shiftMonth(1),
                ),
              ],
            ),
            Row(
              children: [
                for (final day in _weekdays)
                  Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                  ),
              ],
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cellCount,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                final dayNumber = index - leading + 1;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const SizedBox.shrink();
                }
                final date = DateTime(_month.year, _month.month, dayNumber);
                final iso = AppDateUtils.toIsoDate(date);
                final dayEntries = byDay[iso] ?? const <SummaryEntry>[];
                final hasOverdue = dayEntries.any((e) => e.overdue);
                final isHoliday = holidayByIso.containsKey(iso);
                final isSelected = _selected != null && AppDateUtils.isSameDay(_selected!, date);
                final isToday = AppDateUtils.isSameDay(DateTime.now(), date);

                return InkWell(
                  onTap: () => setState(() {
                    _selected = isSelected ? null : date;
                  }),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    margin: const EdgeInsets.all(1),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: hasOverdue
                            ? const Color(0xFFD32F2F)
                            : (isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant),
                        width: (isSelected || hasOverdue) ? 2 : 1,
                      ),
                      color: hasOverdue
                          ? const Color(0xFFFFEBEE)
                          : (isHoliday
                              ? theme.colorScheme.errorContainer.withValues(alpha: 0.5)
                              : null),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$dayNumber',
                          style: TextStyle(
                            fontWeight: (isToday || hasOverdue) ? FontWeight.bold : FontWeight.normal,
                            color: hasOverdue
                                ? const Color(0xFFB71C1C)
                                : (isHoliday ? theme.colorScheme.error : null),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (dayEntries.isNotEmpty)
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 1,
                            runSpacing: 1,
                            children: [
                              for (final entry in dayEntries.take(3))
                                CatAvatar(
                                  avatarId: catById[entry.catId]?.avatarId ?? entry.avatarId,
                                  catColor: catById[entry.catId]?.color ?? entry.catColor,
                                  radius: 7,
                                  fallbackName: entry.catName,
                                ),
                              if (dayEntries.length > 3)
                                Text('+${dayEntries.length - 3}', style: const TextStyle(fontSize: 9)),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // 1. Summary
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selected == null
                        ? 'Summary ${AppDateUtils.formatMonthYear(_month)}'
                        : 'Summary ${AppDateUtils.formatDate(_selected!)}',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (_selected != null)
                  TextButton(
                    onPressed: () => setState(() => _selected = null),
                    child: const Text('All'),
                  ),
              ],
            ),
            CareSummaryList(
              entries: shownSummary,
              contextEntries: allEntries,
              emptyText: 'No scheduled or past activities for this period.',
            ),

            const Divider(height: 28),

            // 2. Care History (All Time, Last 3 Months, Last 6 Months, Last 1 Year)
            Text(
              'Care History',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final period in _HistoryPeriod.values) ...[
                    ChoiceChip(
                      label: Text(period.label),
                      selected: _historyPeriod == period,
                      onSelected: (_) => setState(() => _historyPeriod = period),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 6),
            CareSummaryList(
              entries: filteredHistory,
              contextEntries: allEntries,
              emptyText: 'No care history recorded in ${_historyPeriod.label.toLowerCase()}.',
            ),
          ],
        ),
      ),
    );
  }

  void _openCatRoute(List<Cat> cats, {required bool isHistory}) {
    final targetCatId = _activeCatId;
    if (targetCatId != null) {
      final route = isHistory ? AppRoutes.groomingHistory : AppRoutes.scheduleSetup;
      context.push(route.location(pathParameters: {AppRoutes.catIdParam: targetCatId}));
      return;
    }
    if (cats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a cat profile from Home first.')),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                isHistory ? 'Select a cat to add history' : 'Select a cat to schedule',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            for (final cat in cats)
              ListTile(
                leading: CatAvatar(
                  avatarId: cat.avatarId,
                  catColor: cat.color,
                  radius: 18,
                  fallbackName: cat.name,
                ),
                title: Text(cat.name),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  final route =
                      isHistory ? AppRoutes.groomingHistory : AppRoutes.scheduleSetup;
                  context.push(
                    route.location(pathParameters: {AppRoutes.catIdParam: cat.catId}),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
