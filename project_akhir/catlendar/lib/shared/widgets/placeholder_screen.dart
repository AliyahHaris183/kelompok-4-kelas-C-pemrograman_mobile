import 'package:flutter/material.dart';

/// Layar placeholder bersama untuk semua halaman yang belum diimplementasikan.
/// Ganti isi layar dengan UI sebenarnya; widget ini bisa dihapus dari layar
/// yang sudah selesai.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.screenName,
    required this.featureName,
    required this.owner,
    this.screenNumber,
    this.description,
    this.details = const {},
    this.actions = const [],
  });

  final String screenName;
  final String featureName;
  final String owner;

  /// Nomor layar pada dokumen alur (bagian 5).
  final int? screenNumber;

  /// Ringkasan aksi dan validasi dari dokumen alur.
  final String? description;

  /// Informasi tambahan, mis. parameter rute.
  final Map<String, String> details;

  /// Tombol/aksi tambahan (mis. Log out di Settings).
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final number = screenNumber;
    final summary = description;

    return Scaffold(
      appBar: AppBar(title: Text(screenName)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.construction_outlined,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                screenName,
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                number == null
                    ? 'Fitur: $featureName'
                    : 'Layar $number - Fitur: $featureName',
                textAlign: TextAlign.center,
              ),
              Text('Penanggung jawab: $owner', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              const Text(
                'Implementasi UI dan logika akan diisi oleh anggota terkait.',
                textAlign: TextAlign.center,
              ),
              if (summary != null) ...[
                const SizedBox(height: 16),
                Text(summary, style: theme.textTheme.bodyMedium),
              ],
              if (details.isNotEmpty) ...[
                const SizedBox(height: 16),
                for (final entry in details.entries)
                  Text('${entry.key}: ${entry.value}'),
              ],
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 24),
                ...actions,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
