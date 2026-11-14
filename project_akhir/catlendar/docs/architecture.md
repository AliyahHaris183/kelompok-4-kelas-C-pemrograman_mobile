# Arsitektur Catlendar

Feature-first dengan tiga layer sederhana per fitur (data, domain, presentation).
Riverpod (`flutter_riverpod` 2.x, tanpa code generation) adalah satu-satunya
state management. go_router mengatur navigasi dari satu konfigurasi.

## Struktur folder

```
lib/
  main.dart                  Hanya memanggil bootstrap()
  app/
    bootstrap.dart           Init Firebase, ProviderScope, runApp
    catlendar_app.dart       MaterialApp.router + theme
    dev_menu_screen.dart     Menu sementara untuk membuka semua layar
    firebase_status_banner.dart
    router/
      app_routes.dart        Nama dan path semua rute
      app_router.dart        SATU konfigurasi GoRouter + redirect auth (TODO)
    theme/                   AppTheme, AppColors, AppTextStyles (placeholder)
  core/                      Dipakai semua fitur. Tidak boleh import dari features/
    constants/               Nama koleksi/field Firestore, konstanta, avatar preset
    errors/                  AppException
    firebase/                FirebaseInitializer (satu-satunya init Firebase)
    notifications/           Kontrak LocalNotificationService dan FcmService
    providers/               Provider bersama: Firebase, sesi login, http, notifikasi
    utils/                   AppDateUtils, Validators, konverter Firestore
    widgets/                 LoadingView, ErrorView, EmptyView, AsyncValueView
  shared/
    widgets/                 PrimaryButton, AppTextField, AvatarSelector,
                             ConfirmDialog, PlaceholderScreen
  features/
    auth/   (Orang 1)        data/{models,datasources,repositories}
    cats/   (Orang 2)        domain/repositories
    care/   (Orang 3)        presentation/{providers,screens,widgets}
```

Pembagian `core/widgets` dan `shared/widgets`: `core/widgets` berisi tampilan
state (loading/error/empty) yang hanya bergantung pada core. `shared/widgets`
berisi komponen UI interaktif yang dipakai lintas fitur.

## Alur data

```
Screen (ConsumerWidget)
   | ref.watch / ref.read
Provider (presentation/providers)   AsyncValue / StreamProvider / AsyncNotifier
   |
Repository (domain = kontrak, data = implementasi)
   |
DataSource (Firestore / HTTP)  ->  Model (toMap / fromMap)
```

Aturan: layar hanya membaca state dan memanggil method controller. Layar tidak
memanggil Firestore atau Firebase Auth langsung. Repository mengambil instance
Firebase dari provider di `core/providers/firebase_providers.dart`.

Dependensi antar-fitur dibuat seminimal mungkin. Data lintas fitur (UID
pengguna) dibaca dari `currentUserIdProvider` di core. Jika fitur A butuh data
fitur B, baca lewat provider fitur B, jangan menyalin logikanya.

## Aturan penempatan file

| Jenis file | Lokasi |
|---|---|
| Layar | `features/<fitur>/presentation/screens/` |
| Widget khusus fitur | `features/<fitur>/presentation/widgets/` |
| Provider/Notifier fitur | `features/<fitur>/presentation/providers/` |
| Kontrak repository | `features/<fitur>/domain/repositories/` |
| Implementasi repository | `features/<fitur>/data/repositories/` |
| Akses Firestore/HTTP mentah | `features/<fitur>/data/datasources/` |
| Model | `features/<fitur>/data/models/` |
| Widget generik lintas fitur | `shared/widgets/` atau `core/widgets/` |
| Rute baru | `app/router/app_routes.dart` + `app_router.dart` |
| Nama koleksi/field | `core/constants/` (jangan tulis string di tempat lain) |

Jangan: membuat router per fitur, memanggil `Firebase.initializeApp` di fitur,
memakai `FirebaseFirestore.instance` langsung, menambah package state
management lain, atau menambah field/entitas di luar ERD.

## Kontrak data

Lima koleksi: `USERS`, `CATS`, `MEDICAL_HISTORY`, `CARE_RECORD`, `SCHEDULE`.
Model Dart: `AppUser`, `Cat`, `MedicalHistory`, `CareRecord`, `Schedule`
(`AppUser` dipakai agar tidak bentrok dengan `User` milik firebase_auth).

- Properti Dart memakai camelCase; serialisasi memakai nama field ERD lewat
  `FirestoreFields`.
- Setiap dokumen menyimpan primary key sebagai field **dan** sebagai ID
  dokumen. `fromFirestore` memakai ID dokumen sebagai sumber utama.
- Field bertipe `date` (date_of_birth, performed_date, next_date) disimpan
  sebagai Timestamp 00:00 UTC pada tanggal kalender tersebut, dibaca kembali
  sebagai tanggal lokal tanpa jam. Ini mencegah tanggal bergeser antar zona waktu.
- `care_type` dan `reminder_option` dimodelkan sebagai enum (`CareType`,
  `ReminderOption`) dan disimpan dengan nilai string dari ERD.
- `CARE_RECORD` adalah log: tidak ada `updated_at`, tidak ada update/delete di
  repository maupun di Security Rules.
- `CatBreed` dan `Holiday` adalah model respons API, bukan entitas ERD, dan
  tidak disimpan ke Firestore.

## Hal penting untuk implementasi (mudah terlewat)

1. **Query harus memuat `owner_id`.** Security Rules memeriksa `owner_id` pada
   setiap dokumen. Firestore menolak query list yang tidak bisa dibuktikan aman,
   jadi query berdasarkan `cat_id` saja akan ditolak. Selalu tambahkan
   `where('owner_id', isEqualTo: uid)`. Kontrak repository sudah mewajibkan
   parameter `ownerId`.
2. **Composite index.** Equality pada beberapa field aman. Namun kombinasi
   filter equality dengan `orderBy` (mis. `performed_date` terbaru) butuh
   composite index. Firestore akan memberi tautan pembuatan index di pesan error.
3. **Notifikasi lokal.** `local_notification_id` di ERD bertipe string,
   sedangkan flutter_local_notifications memakai id int. Orang 3 menetapkan satu
   pemetaan string ke int yang konsisten. Saat jadwal diubah: batalkan notifikasi
   lama, lalu jadwalkan yang baru.
4. **Penghapusan kucing.** Security Rules mengizinkan delete `CATS`, tetapi alur
   v3 tidak punya layar hapus kucing dan `CARE_RECORD` tidak bisa dihapus
   (akan menjadi data yatim). Karena itu `CatRepository` sengaja tidak punya
   `deleteCat`. Putuskan sebagai tim sebelum menambahkannya.
5. **Email sudah terdaftar.** Deteksi dilakukan saat `createUser...` gagal dengan
   kode `email-already-in-use`, bukan lewat pengecekan terpisah sebelum itu.
6. **Keterbatasan Security Rules.** Rules memeriksa `owner_id`, tetapi tidak
   memeriksa bahwa `cat_id` pada MEDICAL_HISTORY/CARE_RECORD/SCHEDULE milik
   pengguna yang sama. Untuk proyek ini diterima; catat jika ingin diperketat.

## Notifikasi

- FCM token disimpan di `USERS.fcm_token` saat login dan dihapus saat log out
  (Orang 1, lewat `FcmService`).
- Pengingat jadwal memakai notifikasi lokal terjadwal (Orang 3, lewat
  `LocalNotificationService`).
- Push FCM dikirim manual dari Firebase Console sebagai bukti integrasi.
  Pengiriman otomatis dari server butuh Cloud Functions, yang tidak dipakai.
  Kerangka service di repository ini tidak mengklaim fitur tersebut.

## Navigasi

Semua rute ada di `app_routes.dart` (nama dan path) dan dipasang di
`app_router.dart`. Rute berparameter: `/cats/:catId`, `/cats/:catId/edit`,
`/cats/:catId/grooming-history`, `/cats/:catId/schedule`. Kalender dan Summary
menerima `?catId=` opsional. `/cats/add` dan `/cats/summary` ditempatkan sebelum
`/cats/:catId` agar tidak tertangkap sebagai parameter.

Rute awal sementara adalah `/dev`. Setelah autentikasi selesai, ganti
`AppRoutes.initialLocation` ke `/hello` dan isi fungsi `_redirect`.

## Pembagian kerja

| Anggota | Folder | Layar (nomor alur) | Tanggung jawab |
|---|---|---|---|
| Orang 1 | `features/auth/` | 1-11, 21-24 | Auth, USERS, verifikasi email, reset/ubah password, profil pemilik, FCM token, redirect router |
| Orang 2 | `features/cats/` | 12-16 | CATS, MEDICAL_HISTORY, TheCatAPI, Home, profil kucing, tambah/edit kucing |
| Orang 3 | `features/care/` | 17-20 | CARE_RECORD, SCHEDULE, kalender, Summary, notifikasi lokal, Holiday API |

Layar 24 (Log out) adalah aksi konfirmasi di Settings
(`auth/presentation/widgets/logout_confirmation.dart`), bukan file layar terpisah.

Alur kerja: satu branch per orang, gabung lewat pull request, `flutter analyze`
harus bersih sebelum merge. Perubahan pada `core/`, `shared/`, `app/`, atau
model/ERD harus disepakati bertiga.
