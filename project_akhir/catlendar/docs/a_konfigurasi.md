# Konfigurasi

## Firebase

Sudah dikonfigurasi dan file konfigurasinya ada di repository. Tidak ada yang
perlu diatur. Semua anggota memakai satu proyek Firebase yang sama.

Layanan yang dipakai: Authentication (Email/Password), Cloud Firestore, Cloud
Messaging. Storage dan Cloud Functions tidak dipakai.

Security Rules ada di `firestore.rules` dan sudah di-deploy. Jika aturan perlu
diubah, bicarakan di grup dulu. Orang 1 yang men-deploy ulang. Hasil ujinya ada
di [firestore_rules_testing.md](firestore_rules_testing.md).

## API key

1. Salin `env.example.json` menjadi `env.json`, lalu isi `THE_CAT_API_KEY`
   (minta ke Orang 1 lewat chat pribadi).
2. Jalankan aplikasi dengan:

   ```powershell
   flutter run --dart-define-from-file=env.json
   ```

`env.json` ada di `.gitignore`. Jangan di-commit.

## Holiday Indonesia API (Orang 3)

Belum diputuskan. Setelah tim memilih API-nya:

1. Isi `AppConstants.holidayApiBaseUrl`.
2. Jika API butuh key, tambahkan `HOLIDAY_API_KEY` di `env.example.json` dan
   `AppConstants`.
3. Implementasikan `HolidayApiDataSource` dan `Holiday.fromJson`.

## Notifikasi (Orang 3; token FCM milik Orang 1)

- Android 13 ke atas memerlukan izin runtime notifikasi.
- Setup Android untuk `flutter_local_notifications` mengikuti dokumentasi paket
  tersebut.
- Notifikasi terjadwal butuh paket `timezone`: `flutter pub add timezone`.
- Uji FCM: ambil `fcm_token` dari dokumen USERS, lalu kirim pesan uji dari
  Firebase Console (Messaging, Send test message).

## Masalah umum

- **Banner merah "Firebase belum terkonfigurasi":** baris di bawah banner
  berisi penyebabnya. Kirim ke Orang 1.
- **Build Android gagal soal `minSdkVersion`:** ubah `minSdk` menjadi 23 di
  `android/app/build.gradle` (atau `build.gradle.kts`).
- **Breed tidak muncul:** jalankan dengan `--dart-define-from-file=env.json`.
