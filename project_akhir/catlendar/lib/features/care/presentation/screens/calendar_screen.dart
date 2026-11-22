import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/core/utils/date_utils.dart';
import 'package:catlendar/features/cats/data/models/cat.dart';
import 'package:catlendar/core/widgets/cat_avatar.dart';
import 'package:catlendar/features/care/presentation/theme/care_theme.dart';
import 'package:catlendar/features/care/data/models/holiday.dart';
import 'package:catlendar/features/care/presentation/providers/care_providers.dart';
import 'package:catlendar/features/care/presentation/utils/summary_builder.dart';
import 'package:catlendar/features/care/presentation/widgets/care_summary_list.dart';
import 'package:catlendar/features/cats/presentation/providers/cat_providers.dart';

/// Layar 19: Do you keep everything on track? (kalender bulanan).
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

  @override
  Widget build(BuildContext context) {
    return Theme(data: CareTheme.of(context), child: _body(context));
  }

  Widget _body(BuildContext context) {
    final theme = Theme.of(context);
    final schedules = ref.watch(schedulesByOwnerProvider);
    final records = ref.watch(careRecordsByOwnerProvider);
    final cats = ref.watch(userCatsProvider);
    final holidays = ref.watch(holidaysProvider(_month.year));

    if (schedules.hasError || records.hasError || cats.hasError) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _handleBack),
          title: const Text('Calendar'),
        ),
        body: const Center(child: Text('Kalender belum bisa dimuat.')),
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
    final catId = widget.catId;
    final title = catId == null
        ? 'Do you keep everything on track?'
        : "${catById[catId]?.name ?? 'Kucing'}'s calendar";

    final allEntries = buildSummaryEntries(
      schedules: scheduleList,
      records: recordList,
      cats: catList,
      catId: catId,
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
    final shown = _selected == null
        ? monthEntries
        : monthEntries
            .where((e) => AppDateUtils.isSameDay(e.date, _selected!))
            .toList();

    final leading = DateTime(_month.year, _month.month, 1).weekday - 1;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final cellCount = ((leading + daysInMonth) / 7).ceil() * 7;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBack,
        ),
        title: Text(title),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addSchedule(catList),
        backgroundColor: CareTheme.ink,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        icon: const Icon(Icons.add),
        label: const Text('Set a Schedule'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            if (holidays.hasError)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Data hari libur belum tersedia. Kalender dan jadwal tetap berfungsi.',
                ),
              ),
            Row(
              children: [
                IconButton(
                  tooltip: 'Bulan sebelumnya',
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
                  tooltip: 'Bulan berikutnya',
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
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                        width: isSelected ? 2 : 1,
                      ),
                      color: isHoliday
                          ? theme.colorScheme.errorContainer.withValues(alpha: 0.5)
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$dayNumber',
                          style: TextStyle(
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: isHoliday ? theme.colorScheme.error : null,
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selected == null
                        ? 'Summary ${AppDateUtils.formatMonthYear(_month)}'
                        : 'Aktivitas ${AppDateUtils.formatDate(_selected!)}',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (_selected != null)
                  TextButton(
                    onPressed: () => setState(() => _selected = null),
                    child: const Text('Semua'),
                  ),
              ],
            ),
            CareSummaryList(
              entries: shown,
              emptyText: 'Belum ada jadwal atau riwayat.',
            ),
          ],
        ),
      ),
    );
  }

  void _addSchedule(List<Cat> cats) {
    final catId = widget.catId;
    if (catId != null) {
      context.push(
        AppRoutes.scheduleSetup.location(pathParameters: {AppRoutes.catIdParam: catId}),
      );
      return;
    }
    if (cats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan kucing dulu dari Home.')),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Pilih kucing', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  context.push(
                    AppRoutes.scheduleSetup
                        .location(pathParameters: {AppRoutes.catIdParam: cat.catId}),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
