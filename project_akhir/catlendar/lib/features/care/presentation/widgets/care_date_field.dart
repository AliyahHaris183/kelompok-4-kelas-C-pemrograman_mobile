import 'package:flutter/material.dart';

import 'package:catlendar/core/utils/date_utils.dart';
import 'package:catlendar/features/care/presentation/theme/care_theme.dart';

/// Pilih tanggal dengan kalender bawaan Flutter.
Future<DateTime?> pickCareDate(
  BuildContext context, {
  DateTime? initial,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  final today = AppDateUtils.dateOnly(DateTime.now());
  var start = initial ?? today;
  if (start.isBefore(firstDate)) start = firstDate;
  if (start.isAfter(lastDate)) start = lastDate;
  return showDatePicker(
    context: context,
    initialDate: start,
    firstDate: firstDate,
    lastDate: lastDate,
  );
}

/// Kolom tanggal berbentuk pil dengan ikon di kiri, sesuai desain Figma
/// (Next bath, Last bath, dan seterusnya).
class CareDateField extends StatelessWidget {
  const CareDateField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.onPick,
    required this.onClear,
  });

  final String label;
  final IconData icon;
  final DateTime? value;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 56,
        padding: const EdgeInsets.only(left: 18, right: 4),
        decoration: BoxDecoration(
          border: Border.all(color: CareTheme.outline),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: CareTheme.ink),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasValue ? AppDateUtils.formatDate(value!) : label,
                overflow: TextOverflow.ellipsis,
                style: hasValue
                    ? textStyle?.copyWith(fontWeight: FontWeight.w600)
                    : textStyle?.copyWith(color: CareTheme.muted),
              ),
            ),
            if (hasValue)
              IconButton(
                tooltip: 'Hapus tanggal',
                icon: const Icon(Icons.close, size: 20),
                onPressed: onClear,
              ),
          ],
        ),
      ),
    );
  }
}
