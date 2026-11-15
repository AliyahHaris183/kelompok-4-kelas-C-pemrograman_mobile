import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Email yang diketik di layar Sign up, dibawa ke layar Create password.
/// Password sengaja TIDAK disimpan di state.
class SignUpEmailNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setEmail(String email) => state = email.trim();

  void clear() => state = '';
}

final signUpEmailProvider = NotifierProvider<SignUpEmailNotifier, String>(
  SignUpEmailNotifier.new,
);

/// Draft profil pemilik selama onboarding (layar 9, 10, 11).
/// Tidak ada yang ditulis ke Firestore sampai tombol Save di layar Ringkasan.
class ProfileDraft {
  const ProfileDraft({
    this.avatarId,
    this.name = '',
    this.dateOfBirth,
    this.gender,
  });

  final String? avatarId;
  final String name;

  /// Tanggal saja, tanpa jam.
  final DateTime? dateOfBirth;
  final String? gender;

  ProfileDraft copyWith({
    String? avatarId,
    String? name,
    DateTime? dateOfBirth,
    String? gender,
  }) {
    return ProfileDraft(
      avatarId: avatarId ?? this.avatarId,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
    );
  }
}

class ProfileDraftNotifier extends Notifier<ProfileDraft> {
  @override
  ProfileDraft build() => const ProfileDraft();

  void setAvatar(String avatarId) => state = state.copyWith(avatarId: avatarId);

  void setName(String name) => state = state.copyWith(name: name.trim());

  void setDateOfBirth(DateTime date) => state = state.copyWith(
        dateOfBirth: DateTime(date.year, date.month, date.day),
      );

  void setGender(String gender) => state = state.copyWith(gender: gender);

  void clear() => state = const ProfileDraft();
}

final profileDraftProvider =
    NotifierProvider<ProfileDraftNotifier, ProfileDraft>(
  ProfileDraftNotifier.new,
);
