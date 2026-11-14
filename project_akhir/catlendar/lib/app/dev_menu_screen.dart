import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:catlendar/app/router/app_routes.dart';

/// Menu sementara untuk membuka semua layar placeholder selama pengembangan.
/// TODO(tim): hapus bersama AppRoutes.devMenu setelah alur Hello -> Home jadi.
class DevMenuScreen extends StatelessWidget {
  const DevMenuScreen({super.key});

  static const String _sampleCatId = 'sample-cat-id';

  @override
  Widget build(BuildContext context) {
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
