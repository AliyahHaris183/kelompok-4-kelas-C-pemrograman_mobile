import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catlendar/core/providers/firebase_providers.dart';
import 'package:catlendar/core/providers/http_provider.dart';
import 'package:catlendar/core/providers/session_providers.dart';
import 'package:catlendar/features/cats/data/datasources/cat_breed_api_data_source.dart';
import 'package:catlendar/features/cats/data/datasources/cat_firestore_data_source.dart';
import 'package:catlendar/features/cats/data/datasources/medical_history_firestore_data_source.dart';
import 'package:catlendar/features/cats/data/models/cat.dart';
import 'package:catlendar/features/cats/data/models/cat_breed.dart';
import 'package:catlendar/features/cats/data/models/medical_history.dart';
import 'package:catlendar/features/cats/data/repositories/cat_repository_impl.dart';
import 'package:catlendar/features/cats/data/repositories/medical_history_repository_impl.dart';
import 'package:catlendar/features/cats/domain/repositories/cat_repository.dart';
import 'package:catlendar/features/cats/domain/repositories/medical_history_repository.dart';

final catRepositoryProvider = Provider<CatRepository>(
  (ref) => CatRepositoryImpl(
    CatFirestoreDataSource(ref.watch(firebaseFirestoreProvider)),
  ),
);

final medicalHistoryRepositoryProvider = Provider<MedicalHistoryRepository>(
  (ref) => MedicalHistoryRepositoryImpl(
    MedicalHistoryFirestoreDataSource(ref.watch(firebaseFirestoreProvider)),
  ),
);

final catBreedDataSourceProvider = Provider<CatBreedApiDataSource>(
  (ref) => CatBreedApiDataSource(ref.watch(httpClientProvider)),
);

/// Daftar breed dari TheCatAPI (pendukung).
final breedsProvider = FutureProvider<List<CatBreed>>(
  (ref) => ref.watch(catBreedDataSourceProvider).fetchBreeds(),
);

/// Semua kucing milik pengguna yang sedang login (untuk Home).
final userCatsProvider = StreamProvider<List<Cat>>((ref) {
  final ownerId = ref.watch(currentUserIdProvider);
  if (ownerId == null) return Stream.value(const <Cat>[]);
  return ref.watch(catRepositoryProvider).watchCatsByOwner(ownerId);
});

/// Satu kucing berdasarkan cat_id (untuk profil kucing).
final catByIdProvider = StreamProvider.family<Cat?, String>(
  (ref, catId) => ref.watch(catRepositoryProvider).watchCat(catId),
);

/// Riwayat medis satu kucing.
final medicalHistoryByCatProvider =
    StreamProvider.family<List<MedicalHistory>, String>((ref, catId) {
  final ownerId = ref.watch(currentUserIdProvider);
  if (ownerId == null) return Stream.value(const <MedicalHistory>[]);
  return ref
      .watch(medicalHistoryRepositoryProvider)
      .watchHistoryByCat(ownerId: ownerId, catId: catId);
});

/// Contoh pola AsyncNotifier untuk simpan kucing.
///
/// TODO(Orang 2): tambahkan updateCat, simpan MEDICAL_HISTORY, dan draft form
/// (Add/Edit -> Ringkasan kucing) memakai Notifier terpisah.
class CatEditorController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> createCat(Cat cat) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(catRepositoryProvider).createCat(cat),
    );
  }
}

final catEditorControllerProvider =
    AsyncNotifierProvider<CatEditorController, void>(CatEditorController.new);
