# Catlendar

Aplikasi untuk pemilik kucing: profil kucing, riwayat medis, riwayat perawatan,
jadwal perawatan, kalender, dan pengingat. Proyek mata kuliah Pemrograman Mobile,
dikerjakan bertiga (Orang 1, Orang 2, Orang 3).

Sumber kebenaran data adalah dokumen ERD Catlendar Versi 3 (revisi). Nama
koleksi dan field Firestore mengikuti ERD persis.

## Teknologi

- Flutter dan Dart
- Riverpod (`flutter_riverpod`, tanpa code generation) untuk state management
- go_router untuk navigasi
- Firebase Authentication, Cloud Firestore, Firebase Cloud Messaging
- flutter_local_notifications untuk pengingat terjadwal
- TheCatAPI (daftar breed) dan Holiday Indonesia API (hari libur kalender)

Tidak dipakai: Firebase Storage, Cloud Functions, geolocator, permission
lokasi, map, upload foto. Foto diganti avatar preset lewat `avatar_id`.

## Status saat ini

Sudah selesai (fondasi umum, dibuat Orang 1):

- Entry point, routing, theme, dan inisialisasi Firebase
- Provider Riverpod bersama dan widget reusable
- Model data untuk lima entitas ERD beserta unit test
- Kontrak repository, datasource, dan 23 layar placeholder
- Proyek Firebase dan Firestore Security Rules

Belum selesai, dikerjakan masing-masing:

- Isi fitur: login, CRUD Firestore, jadwal, notifikasi, kalender
- Ditandai komentar `TODO(Orang 1)`, `TODO(Orang 2)`, atau `TODO(Orang 3)`

## Setelah clone (Orang 2 dan Orang 3)

Firebase sudah dikonfigurasi dan filenya ada di repository. Tidak ada yang
perlu diatur.

1. Unduh dependency.

   ```powershell
   flutter pub get
   ```

2. Salin `env.example.json` menjadi `env.json`, lalu isi API key (minta ke
   Orang 1 lewat chat pribadi). Jangan commit file ini.

   ```powershell
   Copy-Item env.example.json env.json
   ```

3. Jalankan di emulator atau HP Android.

   ```powershell
   flutter run --dart-define-from-file=env.json
   ```

Aplikasi dibuka di layar Hello, lalu mengikuti status login: belum login ke
Welcome dan Log in, sudah login langsung ke Greeting dan Home. Aturan akses
ada di `lib/app/router/route_guard.dart`.

## Membuka Dev Menu (untuk pengembangan)

Layar fitur hanya bisa dibuka setelah login, jadi tersedia Dev Menu: daftar
semua layar. Ubah `DEV_MENU` menjadi `true` di `env.json` kalian sendiri, lalu
jalankan ulang aplikasi. Login sekali dengan akun uji (sesi tetap tersimpan),
lalu layar mana pun bisa dibuka dari menu.

## Bagian kerja masing-masing

- **Orang 1** mengerjakan `lib/features/auth/`: login, daftar, verifikasi
  email, lupa dan ubah password, profil pemilik, pengaturan, token FCM.
- **Orang 2** mengerjakan `lib/features/cats/`: data kucing, riwayat medis,
  daftar breed, Home, profil kucing, tambah dan edit kucing.
- **Orang 3** mengerjakan `lib/features/care/`: riwayat perawatan, jadwal,
  kalender, Summary, notifikasi lokal, hari libur.

Hanya edit folder fitur sendiri. Folder lain (`core`, `shared`, `app`) dipakai
bersama, jadi perubahannya dibicarakan dulu di grup.

Mencari TODO milik kalian: di VS Code tekan `Ctrl+Shift+F` lalu cari
`TODO(Orang 2)` (atau 1, atau 3).

## Sebelum menggabungkan pekerjaan

```powershell
flutter analyze      # harus bersih
flutter test         # harus lulus
```

Aturan kerja tim ada di [docs/panduan_tim.md](docs/panduan_tim.md).

## Dokumentasi

- [docs/panduan_tim.md](docs/panduan_tim.md): alur kerja, git, aturan menulis kode.
- [docs/architecture.md](docs/architecture.md): struktur folder dan alur data.
- [docs/konfigurasi.md](docs/konfigurasi.md): API key, Holiday API, notifikasi, masalah umum.
- [docs/firestore_rules_testing.md](docs/firestore_rules_testing.md): hasil uji Security Rules.
