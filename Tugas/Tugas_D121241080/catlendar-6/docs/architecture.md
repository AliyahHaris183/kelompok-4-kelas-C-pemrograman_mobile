# Arsitektur Catlendar

Feature-first dengan tiga layer sederhana per fitur: data, domain, presentation.
Riverpod (`flutter_riverpod` 2.x, tanpa code generation) adalah satu-satunya
state management. go_router mengatur navigasi dari satu konfigurasi.

## Struktur folder

```
lib/
  main.dart                    hanya memanggil bootstrap()
  app/
    bootstrap.dart             init Firebase, ProviderScope, runApp
    catlendar_app.dart         MaterialApp.router dan theme
    dev_menu_screen.dart       menu sementara untuk membuka semua layar
    firebase_status_banner.dart
    router/
      app_routes.dart          nama dan path semua rute
      app_router.dart          satu konfigurasi GoRouter dan redirect auth (TODO)
    theme/                     AppTheme, AppColors, AppTextStyles (placeholder)
  core/                        dipakai semua fitur, tidak boleh import dari features/
    constants/                 nama koleksi dan field Firestore, konstanta, avatar preset
    errors/                    AppException
    firebase/                  FirebaseInitializer (satu-satunya init Firebase)
    notifications/             kontrak LocalNotificationService dan FcmService
    providers/                 provider bersama: Firebase, sesi login, http, notifikasi
    utils/                     AppDateUtils, Validators, konverter Firestore
    widgets/                   LoadingView, ErrorView, EmptyView, AsyncValueView
  shared/
    widgets/                   PrimaryButton, AppTextField, AvatarSelector,
                               ConfirmDialog, PlaceholderScreen
  features/
    auth/                      milik Orang 1
    cats/                      milik Orang 2
    care/                      milik Orang 3
```

Isi tiap folder fitur (`auth`, `cats`, `care`):

```
data/
  models/            model Dart (toMap dan fromMap)
  datasources/       akses mentah ke Firestore atau HTTP
  repositories/      implementasi repository
domain/
  repositories/      kontrak (abstract class) repository
presentation/
  providers/         provider dan controller Riverpod
  screens/           layar
  widgets/           widget khusus fitur
```

Pembagian `core/widgets` dan `shared/widgets`:

- `core/widgets` berisi tampilan state (loading, error, empty) yang hanya
  bergantung pada core.
- `shared/widgets` berisi komponen UI interaktif yang dipakai lintas fitur.

## Alur data

```
Screen (ConsumerWidget)
   |  ref.watch / ref.read
Provider (presentation/providers)     AsyncValue, StreamProvider, AsyncNotifier
   |
Repository (domain = kontrak, data = implementasi)
   |
DataSource (Firestore atau HTTP)  ->  Model (toMap / fromMap)
```

Aturan:

- Layar hanya membaca state dan memanggil method controller.
- Layar tidak memanggil Firestore atau Firebase Auth langsung.
- Repository mengambil instance Firebase dari
  `core/providers/firebase_providers.dart`.
- Data lintas fitur (UID pengguna) dibaca dari `currentUserIdProvider`
  di core.
- Jika fitur A butuh data fitur B, baca lewat provider fitur B. Jangan
  menyalin logikanya.

## Aturan penempatan file

- Layar: `features/<fitur>/presentation/screens/`
- Widget khusus fitur: `features/<fitur>/presentation/widgets/`
- Provider dan controller: `features/<fitur>/presentation/providers/`
- Kontrak repository: `features/<fitur>/domain/repositories/`
- Implementasi repository: `features/<fitur>/data/repositories/`
- Akses Firestore atau HTTP mentah: `features/<fitur>/data/datasources/`
- Model: `features/<fitur>/data/models/`
- Widget generik lintas fitur: `shared/widgets/` atau `core/widgets/`
- Rute baru: `app/router/app_routes.dart` lalu `app/router/app_router.dart`
- Nama koleksi dan field: `core/constants/`. Jangan menulis string-nya di
  tempat lain.

Hal yang tidak boleh dilakukan:

- Membuat router per fitur
- Memanggil `Firebase.initializeApp` di dalam fitur
- Memakai `FirebaseFirestore.instance` atau `FirebaseAuth.instance` langsung
- Menambah package state management lain
- Menambah field atau entitas di luar ERD

## Kontrak data

Lima koleksi: `USERS`, `CATS`, `MEDICAL_HISTORY`, `CARE_RECORD`, `SCHEDULE`.

Model Dart: `AppUser`, `Cat`, `MedicalHistory`, `CareRecord`, `Schedule`.
`AppUser` dipakai agar tidak bentrok dengan `User` milik firebase_auth.

- Properti Dart memakai camelCase. Serialisasi memakai nama field ERD lewat
  `FirestoreFields`.
- Setiap dokumen menyimpan primary key sebagai field dan sebagai ID dokumen.
  `fromFirestore` memakai ID dokumen sebagai sumber utama.
- Field bertipe `date` (`date_of_birth`, `performed_date`, `next_date`)
  disimpan sebagai Timestamp 00:00 UTC pada tanggal kalender tersebut, lalu
  dibaca kembali sebagai tanggal lokal tanpa jam. Ini mencegah tanggal
  bergeser antar zona waktu.
- `care_type` dan `reminder_option` dimodelkan sebagai enum (`CareType`,
  `ReminderOption`) dan disimpan dengan nilai string dari ERD.
- `CARE_RECORD` adalah log. Tidak ada `updated_at`, dan tidak ada update atau
  delete, baik di repository maupun di Security Rules.
- `CatBreed` dan `Holiday` adalah model respons API, bukan entitas ERD, dan
  tidak disimpan ke Firestore.

## Hal penting untuk implementasi (mudah terlewat)

1. **Query harus memuat `owner_id`.** Security Rules memeriksa `owner_id` pada
   setiap dokumen. Firestore menolak query list yang tidak bisa dibuktikan aman,
   jadi query berdasarkan `cat_id` saja akan ditolak. Selalu tambahkan
   `where('owner_id', isEqualTo: uid)`. Kontrak repository sudah mewajibkan
   parameter `ownerId`.

2. **Composite index.** Filter equality pada beberapa field aman. Namun filter
   equality yang digabung dengan `orderBy` (misalnya `performed_date` terbaru)
   butuh composite index. Firestore memberi tautan pembuatan index di pesan
   error.

3. **Notifikasi lokal.** `local_notification_id` di ERD bertipe string,
   sedangkan flutter_local_notifications memakai id int. Orang 3 menetapkan satu
   pemetaan string ke int yang konsisten. Saat jadwal diubah: batalkan
   notifikasi lama, lalu jadwalkan yang baru.

4. **Penghapusan kucing.** Security Rules mengizinkan delete `CATS`, tetapi alur
   v3 tidak punya layar hapus kucing, dan `CARE_RECORD` tidak bisa dihapus
   (akan menjadi data yatim). Karena itu `CatRepository` sengaja tidak punya
   `deleteCat`. Putuskan sebagai tim sebelum menambahkannya.

5. **Email sudah terdaftar.** Deteksi dilakukan saat pembuatan akun gagal
   dengan kode `email-already-in-use`, bukan lewat pengecekan terpisah.

6. **Keterbatasan Security Rules.** Rules memeriksa `owner_id`, tetapi tidak
   memeriksa bahwa `cat_id` pada MEDICAL_HISTORY, CARE_RECORD, dan SCHEDULE
   milik pengguna yang sama. Untuk proyek ini diterima. Catat jika ingin
   diperketat.

## Notifikasi

- Token FCM disimpan di `USERS.fcm_token` saat login dan dihapus saat log out
  (Orang 1, lewat `FcmService`).
- Pengingat jadwal memakai notifikasi lokal terjadwal (Orang 3, lewat
  `LocalNotificationService`).
- Push FCM dikirim manual dari Firebase Console sebagai bukti integrasi.
  Pengiriman otomatis dari server butuh Cloud Functions, yang tidak dipakai di
  versi ini. Kerangka service tidak mengklaim fitur tersebut.

## Navigasi

Semua rute ada di `app_routes.dart` (nama dan path) dan dipasang di
`app_router.dart`.

Rute berparameter:

- `/cats/:catId`
- `/cats/:catId/edit`
- `/cats/:catId/grooming-history`
- `/cats/:catId/schedule`

Kalender (`/calendar`) dan Summary (`/summary`) menerima `?catId=` opsional.
`/cats/add` dan `/cats/summary` ditempatkan sebelum `/cats/:catId` agar tidak
tertangkap sebagai parameter.

Rute awal sementara adalah `/dev`. Setelah autentikasi selesai, ganti
`AppRoutes.initialLocation` ke `/hello` dan isi fungsi `_redirect`.

## Pembagian kerja

- **Orang 1** (`features/auth/`): layar 1 sampai 11 dan 21 sampai 24. Auth,
  USERS, verifikasi email, reset dan ubah password, profil pemilik, token FCM,
  redirect router.
- **Orang 2** (`features/cats/`): layar 12 sampai 16. CATS, MEDICAL_HISTORY,
  TheCatAPI, Home, profil kucing, tambah dan edit kucing.
- **Orang 3** (`features/care/`): layar 17 sampai 20. CARE_RECORD, SCHEDULE,
  kalender, Summary, notifikasi lokal, Holiday API.

Layar 24 (Log out) adalah dialog konfirmasi di Settings
(`auth/presentation/widgets/logout_confirmation.dart`), bukan file layar
terpisah.

Alur git dan aturan kerja ada di [panduan_tim.md](panduan_tim.md).
