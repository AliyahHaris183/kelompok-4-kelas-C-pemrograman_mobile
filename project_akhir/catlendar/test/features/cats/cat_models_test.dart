import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catlendar/features/cats/data/models/cat.dart';
import 'package:catlendar/features/cats/data/models/cat_breed.dart';
import 'package:catlendar/features/cats/data/models/medical_history.dart';

void main() {
  final createdAt = DateTime.utc(2026, 1, 10, 8, 30);
  final updatedAt = DateTime.utc(2026, 2, 11, 9, 45);

  group('Cat (CATS)', () {
    final cat = Cat(
      catId: 'cat-1',
      ownerId: 'uid-1',
      name: 'Fred',
      dateOfBirth: DateTime(2024, 4, 2),
      breed: 'Domestic',
      gender: 'Male',
      neuterStatus: 'Neutered',
      color: 'Black',
      avatarId: 'cat_1',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    test('toMap memakai nama field persis seperti ERD', () {
      expect(cat.toMap().keys.toSet(), {
        'cat_id',
        'owner_id',
        'name',
        'date_of_birth',
        'breed',
        'gender',
        'neuter_status',
        'color',
        'avatar_id',
        'created_at',
        'updated_at',
      });
    });

    test('round trip toMap -> fromMap', () {
      final restored = Cat.fromMap(cat.toMap());
      expect(restored.catId, 'cat-1');
      expect(restored.ownerId, 'uid-1');
      expect(restored.name, 'Fred');
      expect(restored.dateOfBirth, DateTime(2024, 4, 2));
      expect(restored.breed, 'Domestic');
      expect(restored.gender, 'Male');
      expect(restored.neuterStatus, 'Neutered');
      expect(restored.color, 'Black');
      expect(restored.avatarId, 'cat_1');
      expect(restored.createdAt.isAtSameMomentAs(createdAt), isTrue);
    });

    test('breed kosong memakai default Domestic, color/avatar boleh null', () {
      final map = cat.toMap()
        ..remove('breed')
        ..remove('color')
        ..remove('avatar_id');
      final restored = Cat.fromMap(map);
      expect(restored.breed, 'Domestic');
      expect(restored.color, isNull);
      expect(restored.avatarId, isNull);
    });

    test('owner_id wajib ada', () {
      final map = cat.toMap()..remove('owner_id');
      expect(() => Cat.fromMap(map), throwsFormatException);
    });
  });

  group('MedicalHistory (MEDICAL_HISTORY)', () {
    final history = MedicalHistory(
      historyId: 'h-1',
      catId: 'cat-1',
      ownerId: 'uid-1',
      conditionName: 'Asma',
      notes: 'Kambuh saat musim hujan',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    test('toMap memakai nama field persis seperti ERD', () {
      expect(history.toMap().keys.toSet(), {
        'history_id',
        'cat_id',
        'owner_id',
        'condition_name',
        'notes',
        'created_at',
        'updated_at',
      });
      expect(history.toMap()['created_at'], isA<Timestamp>());
    });

    test('round trip dan notes null', () {
      final restored = MedicalHistory.fromMap(history.toMap());
      expect(restored.historyId, 'h-1');
      expect(restored.conditionName, 'Asma');
      expect(restored.notes, 'Kambuh saat musim hujan');

      final noNotes = MedicalHistory.fromMap(history.toMap()..remove('notes'));
      expect(noNotes.notes, isNull);
    });
  });

  test('CatBreed.fromJson membaca id dan name', () {
    final breed = CatBreed.fromJson({'id': 'abys', 'name': 'Abyssinian'});
    expect(breed.id, 'abys');
    expect(breed.name, 'Abyssinian');
  });
}
