import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catlendar/features/auth/presentation/providers/profile_providers.dart';

void main() {
  test('draft profil menyimpan dan membersihkan nilai', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(profileDraftProvider.notifier);

    notifier.setName('  Anya ');
    notifier.setDateOfBirth(DateTime(2001, 5, 17, 13, 45));
    notifier.setGender('Female');
    notifier.setAvatar('owner_2');

    final draft = container.read(profileDraftProvider);
    expect(draft.name, 'Anya');
    expect(draft.dateOfBirth, DateTime(2001, 5, 17));
    expect(draft.gender, 'Female');
    expect(draft.avatarId, 'owner_2');

    notifier.clear();
    final cleared = container.read(profileDraftProvider);
    expect(cleared.name, '');
    expect(cleared.dateOfBirth, isNull);
    expect(cleared.gender, isNull);
    expect(cleared.avatarId, isNull);
  });

  test('email sign up disimpan tanpa spasi dan dapat dihapus', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(signUpEmailProvider.notifier).setEmail(' a@b.com ');
    expect(container.read(signUpEmailProvider), 'a@b.com');

    container.read(signUpEmailProvider.notifier).clear();
    expect(container.read(signUpEmailProvider), '');
  });
}
