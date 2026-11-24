import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/core/widgets/cat_avatar.dart';
import 'package:catlendar/features/auth/presentation/providers/auth_providers.dart';
import 'package:catlendar/features/care/presentation/providers/care_providers.dart';
import 'package:catlendar/features/care/presentation/theme/care_theme.dart';
import 'package:catlendar/features/care/presentation/utils/summary_builder.dart';
import 'package:catlendar/features/care/presentation/widgets/care_summary_list.dart';
import 'package:catlendar/features/cats/data/models/cat.dart';
import 'package:catlendar/features/cats/presentation/providers/cat_providers.dart';
import 'package:catlendar/shared/widgets/avatar_image.dart';

enum _SummaryHistoryPeriod {
  allTime('All Time'),
  last3Months('Last 3 Months'),
  last6Months('Last 6 Months'),
  lastYear('Last 1 Year');

  const _SummaryHistoryPeriod(this.label);
  final String label;
}

/// Screen 20: Summary integrated with owner & cat profiles, Upcoming Schedules, and Care History.
class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key, this.catId});

  final String? catId;

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  late String? _activeCatId = widget.catId;
  _SummaryHistoryPeriod _historyPeriod = _SummaryHistoryPeriod.allTime;

  @override
  void didUpdateWidget(covariant SummaryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.catId != widget.catId) {
      _activeCatId = widget.catId;
    }
  }

  List<SummaryEntry> _filterHistory(List<SummaryEntry> history) {
    if (_historyPeriod == _SummaryHistoryPeriod.allTime) return history;
    final now = DateTime.now();
    final DateTime cutoff = switch (_historyPeriod) {
      _SummaryHistoryPeriod.allTime => DateTime(1970),
      _SummaryHistoryPeriod.last3Months => DateTime(now.year, now.month - 3, now.day),
      _SummaryHistoryPeriod.last6Months => DateTime(now.year, now.month - 6, now.day),
      _SummaryHistoryPeriod.lastYear => DateTime(now.year - 1, now.month, now.day),
    };
    return history.where((e) => !e.date.isBefore(cutoff)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final schedules = ref.watch(schedulesByOwnerProvider);
    final records = ref.watch(careRecordsByOwnerProvider);
    final cats = ref.watch(userCatsProvider);
    final userProfile = ref.watch(currentUserProfileProvider).value;
    final theme = Theme.of(context);

    final Widget body;
    if (schedules.hasError || records.hasError || cats.hasError) {
      body = const Center(child: Text('Unable to load summary.'));
    } else if (schedules.value == null || records.value == null || cats.value == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      final catList = cats.value!;
      final catById = {for (final c in catList) c.catId: c};
      final effectiveCatId =
          (_activeCatId != null && catById.containsKey(_activeCatId)) ? _activeCatId : null;
      final selectedCat = effectiveCatId == null ? null : catById[effectiveCatId];

      final entries = buildSummaryEntries(
        schedules: schedules.value!,
        records: records.value!,
        cats: catList,
        catId: effectiveCatId,
      );
      final upcomingEntries = entries.where((e) => e.kind == SummaryKind.next).toList();
      final allHistoryEntries =
          entries.where((e) => e.kind == SummaryKind.last).toList().reversed.toList();
      final filteredHistory = _filterHistory(allHistoryEntries);

      body = ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 14),
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
                                ? 'Summary for all cats (${catList.length})'
                                : 'Profile summary: ${selectedCat.name}',
                            style: theme.textTheme.bodySmall?.copyWith(color: CareTheme.muted),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _openAddHistory(context, catList, effectiveCatId),
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
          Text(
            'Upcoming Schedules',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          CareSummaryList(
            entries: upcomingEntries,
            contextEntries: entries,
            emptyText: 'No upcoming care schedules.',
          ),
          const Divider(height: 28),
          Text(
            'Care History',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final period in _SummaryHistoryPeriod.values) ...[
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
            contextEntries: entries,
            emptyText: 'No care history recorded in ${_historyPeriod.label.toLowerCase()}.',
          ),
        ],
      );
    }

    return Theme(
      data: CareTheme.of(context),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back',
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

  void _openAddHistory(BuildContext context, List<Cat> cats, String? activeCatId) {
    if (activeCatId != null) {
      context.push(
        AppRoutes.groomingHistory.location(pathParameters: {AppRoutes.catIdParam: activeCatId}),
      );
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
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Select a cat to add history', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    AppRoutes.groomingHistory
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
