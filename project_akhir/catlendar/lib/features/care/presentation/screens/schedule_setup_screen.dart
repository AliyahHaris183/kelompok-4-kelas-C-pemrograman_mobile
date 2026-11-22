import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/core/utils/date_utils.dart';
import 'package:catlendar/core/widgets/cat_avatar.dart';
import 'package:catlendar/features/care/data/models/care_type.dart';
import 'package:catlendar/features/care/data/models/holiday.dart';
import 'package:catlendar/features/care/data/models/reminder_option.dart';
import 'package:catlendar/features/care/domain/care_inputs.dart';
import 'package:catlendar/features/care/presentation/providers/care_providers.dart';
import 'package:catlendar/features/care/presentation/utils/care_labels.dart';
import 'package:catlendar/features/care/presentation/theme/care_theme.dart';
import 'package:catlendar/features/care/presentation/widgets/care_date_field.dart';
import 'package:catlendar/features/cats/presentation/providers/cat_providers.dart';

/// Layar 18: Let's schedule your cat's next grooming session!
class ScheduleSetupScreen extends ConsumerStatefulWidget {
  const ScheduleSetupScreen({super.key, required this.catId});

  final String catId;

  @override
  ConsumerState<ScheduleSetupScreen> createState() => _ScheduleSetupScreenState();
}

class _ScheduleSetupScreenState extends ConsumerState<ScheduleSetupScreen> {
  static const List<CareType> _standardTypes = [
    CareType.bath,
    CareType.flea,
    CareType.fungal,
    CareType.vetVisit,
    CareType.vaccination,
  ];

  static const Map<CareType, String> _labels = {
    CareType.bath: 'Next bath',
    CareType.flea: 'Next flea treatment',
    CareType.fungal: 'Next fungal treatment',
    CareType.vetVisit: 'Next vet visit',
    CareType.vaccination: 'Next vaccination',
  };

  final Map<CareType, DateTime?> _dates = {
    for (final type in _standardTypes) type: null,
  };
  final TextEditingController _customName = TextEditingController();
  DateTime? _customDate;
  ReminderOption _reminder = ReminderOption.aWeek;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefill());
  }

  Future<void> _prefill() async {
    final existing = await ref.read(schedulesByCatProvider(widget.catId).future);
    if (!mounted) return;
    final active = existing.where((s) => s.isActive).toList();
    if (active.isEmpty) return;
    setState(() {
      for (final schedule in active) {
        if (schedule.careType == CareType.custom) {
          _customName.text = schedule.customName ?? '';
          _customDate = schedule.nextDate;
        } else if (_dates.containsKey(schedule.careType)) {
          _dates[schedule.careType] = schedule.nextDate;
        }
      }
      _reminder = active.first.reminderOption;
    });
  }

  @override
  void dispose() {
    _customName.dispose();
    super.dispose();
  }

  DateTime _firstAllowed() => AppDateUtils.dateOnly(DateTime.now());

  DateTime _lastAllowed() => DateTime(DateTime.now().year + 3, 12, 31);

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home.path);
    }
  }

  Future<void> _save(String catName) async {
    final name = _customName.text.trim();
    if (_customDate != null && name.isEmpty) {
      _snack('Nama custom event wajib diisi.');
      return;
    }

    final inputs = <ScheduleInput>[
      for (final type in _standardTypes)
        if (_dates[type] != null)
          ScheduleInput(careType: type, nextDate: _dates[type]!),
      if (_customDate != null)
        ScheduleInput(
          careType: CareType.custom,
          customName: name,
          nextDate: _customDate!,
        ),
    ];

    setState(() => _saving = true);
    final result = await ref
        .read(careActionControllerProvider.notifier)
        .saveSchedules(
          catId: widget.catId,
          catName: catName,
          inputs: inputs,
          reminder: _reminder,
        );
    if (!mounted) return;
    setState(() => _saving = false);

    switch (result) {
      case ScheduleSaved(:final savedCount, :final remindersScheduled, :final reminderDenied):
        final notes = <String>[
          '$savedCount jadwal tersimpan.',
          if (reminderDenied)
            'Izin notifikasi ditolak, pengingat tidak dijadwalkan.'
          else if (_reminder != ReminderOption.none)
            '$remindersScheduled pengingat dijadwalkan.',
        ];
        _snack(notes.join(' '));
        _handleBack();
      case ScheduleInvalid(:final messages):
        _snack(messages.join('\n'));
      case ScheduleFailed(:final message):
        _snack(message);
    }
  }

  Widget _holidayNotice(DateTime? date) {
    if (date == null) return const SizedBox.shrink();
    final holidays = ref.watch(holidaysProvider(date.year));
    final list = holidays.value ?? const <Holiday>[];
    Holiday? match;
    for (final holiday in list) {
      if (AppDateUtils.isSameDay(holiday.date, date)) {
        match = holiday;
        break;
      }
    }
    if (match == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 16),
      child: Text(
        'Tanggal ini hari libur: ${match.name}. Jadwal tetap bisa disimpan.',
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(data: CareTheme.of(context), child: _body(context));
  }

  Widget _body(BuildContext context) {
    final theme = Theme.of(context);
    final cat = ref.watch(catByIdProvider(widget.catId)).value;
    final catName = cat?.name ?? 'kucing';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBack,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            Text(
              "Let's schedule your cat's next grooming session!",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 24,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: CatAvatar(
                avatarId: cat?.avatarId,
                catColor: cat?.color,
                radius: 50,
                fallbackName: cat?.name,
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () => context.push(
                  AppRoutes.editCat.location(pathParameters: {AppRoutes.catIdParam: widget.catId}),
                ),
                child: const Text(
                  'Edit profile picture',
                  style: TextStyle(color: CareTheme.ink, decoration: TextDecoration.underline),
                ),
              ),
            ),
            const SizedBox(height: 24),
            for (final type in _standardTypes) ...[
              CareDateField(
                label: _labels[type]!,
                icon: careTypeIcon(type),
                value: _dates[type],
                onPick: () async {
                  final picked = await pickCareDate(
                    context,
                    initial: _dates[type],
                    firstDate: _firstAllowed(),
                    lastDate: _lastAllowed(),
                  );
                  if (picked != null) setState(() => _dates[type] = picked);
                },
                onClear: () => setState(() => _dates[type] = null),
              ),
              _holidayNotice(_dates[type]),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _customName,
              decoration: const InputDecoration(
                hintText: 'Next custom event (nama kegiatan)',
              ),
            ),
            const SizedBox(height: 12),
            CareDateField(
              label: 'Next custom event',
              icon: careTypeIcon(CareType.custom),
              value: _customDate,
              onPick: () async {
                final picked = await pickCareDate(
                  context,
                  initial: _customDate,
                  firstDate: _firstAllowed(),
                  lastDate: _lastAllowed(),
                );
                if (picked != null) setState(() => _customDate = picked);
              },
              onClear: () => setState(() => _customDate = null),
            ),
            _holidayNotice(_customDate),
            const SizedBox(height: 24),
            Text(
              'Remind me?',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            RadioGroup<ReminderOption>(
              groupValue: _reminder,
              onChanged: (value) {
                if (value != null) setState(() => _reminder = value);
              },
              child: Column(
                children: [
                  for (final option in ReminderOption.values)
                    RadioListTile<ReminderOption>(
                      value: option,
                      contentPadding: EdgeInsets.zero,
                      title: Text(reminderLabel(option.value)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : () => _save(catName),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
