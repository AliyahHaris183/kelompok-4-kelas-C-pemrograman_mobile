import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/core/errors/app_exception.dart';
import 'package:catlendar/core/widgets/empty_view.dart';
import 'package:catlendar/core/widgets/error_view.dart';
import 'package:catlendar/core/widgets/loading_view.dart';

/// Menampilkan AsyncValue dengan loading, error, dan (opsional) empty yang seragam.
///
/// Contoh:
/// ```dart
/// AsyncValueView<List<Cat>>(
///   value: ref.watch(userCatsProvider),
///   isEmpty: (cats) => cats.isEmpty,
///   builder: (cats) => ...,
/// )
/// ```
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.builder,
    this.onRetry,
    this.isEmpty,
    this.emptyMessage = 'Belum ada data',
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;
  final bool Function(T data)? isEmpty;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (data) {
        final emptyCheck = isEmpty;
        if (emptyCheck != null && emptyCheck(data)) {
          return EmptyView(message: emptyMessage);
        }
        return builder(data);
      },
      loading: () => const LoadingView(),
      error: (error, stackTrace) =>
          ErrorView(message: AppException.from(error).message, onRetry: onRetry),
    );
  }
}
