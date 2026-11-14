import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/app/firebase_status_banner.dart';
import 'package:catlendar/app/router/app_router.dart';
import 'package:catlendar/app/theme/app_theme.dart';
import 'package:catlendar/core/constants/app_constants.dart';
import 'package:catlendar/core/providers/firebase_providers.dart';

class CatlendarApp extends ConsumerWidget {
  const CatlendarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final firebaseResult = ref.watch(firebaseInitResultProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();
        if (firebaseResult.isInitialized) return content;
        return Column(
          children: [
            FirebaseStatusBanner(message: firebaseResult.errorMessage),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: content,
              ),
            ),
          ],
        );
      },
    );
  }
}
