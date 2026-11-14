import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:catlendar/core/constants/app_constants.dart';
import 'package:catlendar/core/constants/firestore_fields.dart';
import 'package:catlendar/core/utils/firestore_converters.dart';

/// Entitas CATS. Dokumen: CATS/{cat_id}.
class Cat {
  const Cat({
    required this.catId,
    required this.ownerId,
    required this.name,
    required this.dateOfBirth,
    this.breed = AppConstants.defaultBreed,
    required this.gender,
    required this.neuterStatus,
    this.color,
    this.avatarId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String catId;

  /// UID pemilik. Wajib sama dengan uid pengguna (Security Rules).
  final String ownerId;
  final String name;
  final DateTime dateOfBirth;

  /// Dari TheCatAPI, bawaan Domestic.
  final String breed;
  final String gender;
  final String neuterStatus;

  /// Dipilih dari daftar. Tidak termasuk field wajib pada validasi form.
  final String? color;
  final String? avatarId;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Cat.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw FormatException('Dokumen CATS/${doc.id} kosong atau tidak ada');
    }
    return Cat.fromMap({...data, FirestoreFields.catId: doc.id});
  }

  factory Cat.fromMap(Map<String, dynamic> map) {
    return Cat(
      catId: map.readRequiredString(FirestoreFields.catId),
      ownerId: map.readRequiredString(FirestoreFields.ownerId),
      name: map.readRequiredString(FirestoreFields.name),
      dateOfBirth: map.readRequiredDate(FirestoreFields.dateOfBirth),
      breed: map.readString(FirestoreFields.breed) ?? AppConstants.defaultBreed,
      gender: map.readRequiredString(FirestoreFields.gender),
      neuterStatus: map.readRequiredString(FirestoreFields.neuterStatus),
      color: map.readString(FirestoreFields.color),
      avatarId: map.readString(FirestoreFields.avatarId),
      createdAt: map.readRequiredDateTime(FirestoreFields.createdAt),
      updatedAt: map.readRequiredDateTime(FirestoreFields.updatedAt),
    );
  }

  Map<String, dynamic> toFirestore() => toMap();

  Map<String, dynamic> toMap() => {
        FirestoreFields.catId: catId,
        FirestoreFields.ownerId: ownerId,
        FirestoreFields.name: name,
        FirestoreFields.dateOfBirth: dateOnlyToTimestamp(dateOfBirth),
        FirestoreFields.breed: breed,
        FirestoreFields.gender: gender,
        FirestoreFields.neuterStatus: neuterStatus,
        FirestoreFields.color: color,
        FirestoreFields.avatarId: avatarId,
        FirestoreFields.createdAt: dateTimeToTimestamp(createdAt),
        FirestoreFields.updatedAt: dateTimeToTimestamp(updatedAt),
      };
}
