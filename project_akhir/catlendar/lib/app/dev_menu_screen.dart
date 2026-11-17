import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';
import 'package:catlendar/features/auth/presentation/providers/session_status_provider.dart';

/// Menu sementara untuk membuka semua layar placeholder selama pengembangan.
/// TODO(tim): hapus bersama AppRoutes.devMenu setelah alur Hello -> Home jadi.
class DevMenuScreen extends ConsumerWidget {
  const DevMenuScreen({super.key});

  static const String _sampleCatId = 'sample-cat-id';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(sessionStatusProvider);
    final catParams = {AppRoutes.catIdParam: _sampleCatId};

    final sections = <String, List<_DevLink>>{
      'Auth & Settings (Orang 1)': [
        _DevLink('1. Hello', AppRoutes.hello.location()),
        _DevLink('2. Welcome', AppRoutes.welcome.location()),
        _DevLink('3. Log in', AppRoutes.login.location()),
        _DevLink('4. Forgot password', AppRoutes.forgotPassword.location()),
        _DevLink('5. Sign up', AppRoutes.signup.location()),
        _DevLink('6. Create password', AppRoutes.createPassword.location()),
        _DevLink('7. Verifikasi email', AppRoutes.emailVerification.location()),
        _DevLink('8. Greeting', AppRoutes.greeting.location()),
        _DevLink('9. Set up profile', AppRoutes.setupProfile.location()),
        _DevLink('10. Date of birth', AppRoutes.dateOfBirth.location()),
        _DevLink('11. Ringkasan profil', AppRoutes.profileSummary.location()),
        _DevLink('21. Settings', AppRoutes.settings.location()),
        _DevLink('22. Edit profile', AppRoutes.editOwnerProfile.location()),
        _DevLink('23. Change password', AppRoutes.changePassword.location()),
      ],
      'Cats & Home (Orang 2)': [
        _DevLink('12. Add your first cat', AppRoutes.addCat.location()),
        _DevLink('13. Ringkasan kucing', AppRoutes.catSummary.location()),
        _DevLink('14. Home', AppRoutes.home.location()),
        _DevLink(
          '15. Profil kucing',
          AppRoutes.catProfile.location(pathParameters: catParams),
        ),
        _DevLink(
          '16. Edit profil kucing',
          AppRoutes.editCat.location(pathParameters: catParams),
        ),
      ],
      'Care (Orang 3)': [
        _DevLink(
          '17. Grooming history',
          AppRoutes.groomingHistory.location(pathParameters: catParams),
        ),
        _DevLink(
          '18. Schedule setup',
          AppRoutes.scheduleSetup.location(pathParameters: catParams),
        ),
        _DevLink('19. Calendar', AppRoutes.calendar.location()),
        _DevLink('20. Summary', AppRoutes.summary.location()),
      ],
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Catlendar Dev Menu')),
      body: ListView(
        children: [
          _StatusBanner(status: status),
          for (final section in sections.entries) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: Text(
                section.key,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            for (final link in section.value)
              ListTile(
                title: Text(link.title),
                subtitle: Text(link.location),
                onTap: () => context.push(link.location),
              ),
          ],
        ],
      ),
    );
  }
}

class _DevLink {
  const _DevLink(this.title, this.location);

  final String title;
  final String location;
}

/// Menjelaskan status sesi saat ini, karena penjaga router (route_guard.dart)
/// membuat sebagian layar hanya bisa dibuka pada status tertentu.
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status});

  final SessionStatus status;

  String get _message => switch (status) {
        SessionStatus.loading => 'Status sesi belum diketahui.',
        SessionStatus.signedOut =>
          'Belum login. Hanya layar 1-6 yang bisa dibuka. Layar lain '
              'diarahkan ke Welcome.',
        SessionStatus.needsVerification =>
          'Email belum diverifikasi. Semua layar diarahkan ke Verifikasi '
              'email (7).',
        SessionStatus.needsProfile =>
          'Profil belum dibuat. Hanya layar 9-11 yang bisa dibuka. Layar '
              'lain diarahkan ke Set up profile (9).',
        SessionStatus.ready =>
          'Akun lengkap. Layar 1-7 diarahkan ke Greeting lalu Home, dan '
              'layar 9-11 diarahkan ke Add your first cat. Log out dulu '
              '(Settings) untuk melihat layar 1-6.',
        SessionStatus.error =>
          'Status sesi gagal dibaca. Diperlakukan seperti belum login.',
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Status sesi: ${status.name}\n$_message',
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
