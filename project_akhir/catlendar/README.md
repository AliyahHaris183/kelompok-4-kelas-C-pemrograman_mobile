# Catlendar

Aplikasi untuk pemilik kucing: profil kucing, riwayat medis, riwayat perawatan,
jadwal perawatan, kalender, dan pengingat.

Sumber kebenaran data: **Catlendar_ERD_Revised.pdf (Versi 3)**. Nama koleksi dan
field Firestore mengikuti ERD secara persis.

## Teknologi

Flutter, Dart, Riverpod (`flutter_riverpod`, tanpa code generation), go_router,
Firebase Auth, Cloud Firestore, Firebase Cloud Messaging,
flutter_local_notifications, TheCatAPI (pendukung daftar breed), Holiday
Indonesia API (kalender).

Tidak dipakai: Firebase Storage, Cloud Functions, geolocator, permission lokasi,
map, upload foto (foto diganti avatar preset lewat `avatar_id`).

## Status

Ini adalah **scaffold fondasi**. Bagian umum sudah diimplementasikan (entry point,
routing, theme, provider Firebase, widget bersama, utilitas, model, test model).
Bisnis fitur (login, CRUD Firestore, jadwal, notifikasi, kalender) **belum**
diimplementasikan dan ditandai `TODO(Orang N)`.

Scaffold ini dibuat tanpa Flutter SDK, jadi `flutter pub get`, `flutter analyze`,
dan `flutter test` **belum pernah dijalankan** pada kode ini. Jalankan langkah di
bawah dan perbaiki bila ada temuan.

## Menjalankan proyek (pertama kali)

Folder platform (`android/`, `ios/`, dst.) belum ada. Dari dalam folder ini:

```bash
flutter create --project-name catlendar --platforms=android,ios .
git status        # pastikan file di lib/, test/, pubspec.yaml tidak tertimpa
flutter pub get
flutter analyze
flutter test
```

Lalu siapkan Firebase: lihat [docs/firebase_setup.md](docs/firebase_setup.md).

```bash
flutter run --dart-define=THE_CAT_API_KEY=isi_api_key_anda
```

Tanpa konfigurasi Firebase, aplikasi tetap terbuka dengan banner peringatan, dan
semua layar placeholder bisa dibuka lewat **Dev Menu** (rute awal `/dev`).

## Dokumentasi

- [docs/architecture.md](docs/architecture.md): arsitektur, folder, alur data, aturan penempatan file, pembagian kerja.
- [docs/firebase_setup.md](docs/firebase_setup.md): konfigurasi Firebase dan API.
- [docs/firestore_rules_testing.md](docs/firestore_rules_testing.md): skenario uji Security Rules (belum diuji).
