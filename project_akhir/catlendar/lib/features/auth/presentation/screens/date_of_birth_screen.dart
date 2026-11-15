import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/core/utils/date_utils.dart';
import 'package:catlendar/features/auth/presentation/providers/profile_providers.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_button.dart';
import 'package:catlendar/features/auth/presentation/widgets/auth_scaffold.dart';

/// Layar 10: Date of birth. Kalender saja, tanpa jam (keputusan 7.3).
/// Menyimpan tanggal ke draft lalu kembali ke Set up profile.
class DateOfBirthScreen extends ConsumerStatefulWidget {
  const DateOfBirthScreen({super.key});

  @override
  ConsumerState<DateOfBirthScreen> createState() => _DateOfBirthScreenState();
}

class _DateOfBirthScreenState extends ConsumerState<DateOfBirthScreen> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = ref.read(profileDraftProvider).dateOfBirth ??
        AppDateUtils.dateOnly(DateTime.now());
  }

  void _continue() {
    ref.read(profileDraftProvider.notifier).setDateOfBirth(_selected);
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Date of birth',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          CalendarDatePicker(
            initialDate: _selected,
            firstDate: DateTime(1900),
            lastDate: AppDateUtils.dateOnly(DateTime.now()),
            initialCalendarMode: DatePickerMode.year,
            onDateChanged: (date) => setState(() => _selected = date),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              AppDateUtils.formatDate(_selected),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          AuthButton(label: 'Continue', onPressed: _continue),
        ],
      ),
    );
  }
}
