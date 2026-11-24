import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/core/utils/date_utils.dart';
import 'package:catlendar/core/widgets/cat_avatar.dart';
import 'package:catlendar/features/care/data/models/care_type.dart';
import 'package:catlendar/features/care/domain/care_inputs.dart';
import 'package:catlendar/features/care/presentation/providers/care_providers.dart';
import 'package:catlendar/features/care/presentation/theme/care_theme.dart';
import 'package:catlendar/features/care/presentation/utils/care_labels.dart';
import 'package:catlendar/features/care/presentation/widgets/care_date_field.dart';
import 'package:catlendar/features/cats/presentation/providers/cat_providers.dart';

/// Layar 17: Fill in your cat's grooming details.
class GroomingHistoryScreen extends ConsumerStatefulWidget {
  const GroomingHistoryScreen({super.key, required this.catId});

  final String catId;

  @override
  ConsumerState<GroomingHistoryScreen> createState() =>
      _GroomingHistoryScreenState();
}

class _GroomingHistoryScreenState extends ConsumerState<GroomingHistoryScreen> {
  static const List<CareType> _standardTypes = [
    CareType.bath,
    CareType.flea,
    CareType.fungal,
    CareType.vetVisit,
    CareType.vaccination,
  ];

  static const Map<CareType, String> _labels = {
    CareType.bath: 'Last bath',
    CareType.flea: 'Last flea treatment',
    CareType.fungal: 'Last fungal treatment',
    CareType.vetVisit: 'Last vet visit',
    CareType.vaccination: 'Last vaccinated',
  };

  final Map<CareType, DateTime?> _dates = {
    for (final type in _standardTypes) type: null,
  };
  final TextEditingController _customName = TextEditingController();
  DateTime? _customDate;
  bool _saving = false;

  @override
  void dispose() {
    _customName.dispose();
    super.dispose();
  }

  DateTime _lastAllowed() => AppDateUtils.dateOnly(DateTime.now());

  DateTime _firstAllowed() => DateTime(DateTime.now().year - 30);

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.calendar.path);
    }
  }

  List<PastCareInput> _collectInputs() {
    final name = _customName.text.trim();
    return [
      for (final type in _standardTypes)
        if (_dates[type] != null)
          PastCareInput(careType: type, performedDate: _dates[type]!),
      if (_customDate != null)
        PastCareInput(
          careType: CareType.custom,
          customName: name,
          performedDate: _customDate!,
        ),
    ];
  }

  Future<void> _saveOnly() async {
    final name = _customName.text.trim();
    if (_customDate != null && name.isEmpty) {
      _snack('Nama custom event wajib diisi.');
      return;
    }
    final inputs = _collectInputs();
    if (inputs.isEmpty) {
      _snack('Pilih minimal satu tanggal riwayat.');
      return;
    }

    setState(() => _saving = true);
    final error = await ref
        .read(careActionControllerProvider.notifier)
        .saveGroomingRecords(catId: widget.catId, inputs: inputs);
    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      _snack(error);
      return;
    }
    _snack('${inputs.length} riwayat perawatan tersimpan.');
    _handleBack();
  }

  Future<void> _continue() async {
    final name = _customName.text.trim();
    if (_customDate != null && name.isEmpty) {
      _snack('Nama custom event wajib diisi.');
      return;
    }

    final inputs = _collectInputs();

    setState(() => _saving = true);
    final error = await ref
        .read(careActionControllerProvider.notifier)
        .saveGroomingRecords(catId: widget.catId, inputs: inputs);
    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      _snack(error);
      return;
    }
    context.push(
      AppRoutes.scheduleSetup.location(
        pathParameters: {AppRoutes.catIdParam: widget.catId},
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
            Center(
              child: CatAvatar(
                avatarId: cat?.avatarId,
                catColor: cat?.color,
                radius: 40,
                fallbackName: cat?.name,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Fill in your cat's grooming details",
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Semua opsional. Setiap tanggal menjadi satu riwayat baru.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
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
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _customName,
              decoration: const InputDecoration(
                hintText: 'Custom event (nama kegiatan)',
              ),
            ),
            const SizedBox(height: 12),
            CareDateField(
              label: 'Last custom event',
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
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _saving ? null : _saveOnly,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save History'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _saving ? null : _continue,
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              child: const Text('Save & Continue to Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}
