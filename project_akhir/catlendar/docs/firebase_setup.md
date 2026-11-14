# Setup Firebase

Repository ini **tidak** berisi konfigurasi Firebase, API key, atau kredensial.
Semua langkah di bawah dilakukan manual oleh tim. Status centang di bawah
adalah daftar pekerjaan, bukan klaim bahwa sudah dilakukan.

## 1. Proyek Firebase

- [ ] Buat proyek di Firebase Console.
- [ ] Authentication: aktifkan provider **Email/Password**.
- [ ] Firestore: buat database (mode produksi; Security Rules akan di-deploy).
- [ ] Cloud Messaging tersedia otomatis. Untuk iOS, unggah kunci APNs di
      Project settings > Cloud Messaging.
- [ ] Jangan mengaktifkan Storage atau Cloud Functions (tidak dipakai).
- Paket Spark (gratis) cukup untuk fitur yang dipakai.

## 2. Hubungkan aplikasi Flutter

Pilih satu cara.

**Cara A (disarankan): FlutterFire CLI**

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Perintah ini membuat `lib/firebase_options.dart` dan mengonfigurasi platform.
Setelah itu edit `lib/core/firebase/firebase_initializer.dart`: ikuti komentar
TODO di dalamnya untuk memanggil
`Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`.

**Cara B: file konfigurasi native**

Unduh `google-services.json` ke `android/app/` dan `GoogleService-Info.plist`
ke `ios/Runner/`, lalu ikuti panduan Firebase untuk menerapkan plugin Gradle
Google Services di Android. `Firebase.initializeApp()` tanpa opsi (kode saat ini)
akan memakai konfigurasi native tersebut.

`.gitignore` menyembunyikan file konfigurasi ini secara bawaan. Putuskan sebagai
tim apakah akan di-commit. Konfigurasi klien Firebase bukan rahasia seperti
password, tetapi tetap sebaiknya diputuskan sadar.

## 3. Security Rules

File `firestore.rules` sudah ada di root. Deploy:

```bash
firebase login
firebase use <id-proyek-firebase>
firebase deploy --only firestore:rules
```

Aturan **belum diuji**. Jalankan skenario di
[firestore_rules_testing.md](firestore_rules_testing.md) dan catat hasilnya
sebelum menganggap aturan aman.

## 4. TheCatAPI (daftar breed)

- [ ] Daftar untuk API key di situs TheCatAPI.
- Jangan menaruh key di source code. Kirim saat menjalankan:
  `flutter run --dart-define=THE_CAT_API_KEY=isi_key`
- Dibaca lewat `AppConstants.theCatApiKey`.

## 5. Holiday Indonesia API

- [ ] Tim memilih/mengonfirmasi API yang dipakai, lisensi, dan batas
      pemakaiannya (keputusan 7.9 pada dokumen alur).
- [ ] Isi `AppConstants.holidayApiBaseUrl` dan implementasikan
      `HolidayApiDataSource` serta `Holiday.fromJson`. URL dan format respons
      sengaja tidak ditebak di scaffold.

## 6. Notifikasi

- Android 13+ memerlukan izin runtime notifikasi. Setup Android untuk
  `flutter_local_notifications` (receiver, izin, desugaring) mengikuti
  dokumentasi paket tersebut untuk versi yang terpasang.
- Notifikasi terjadwal memakai paket `timezone`; tambahkan dengan
  `flutter pub add timezone` saat mulai implementasi.
- Uji FCM: ambil `fcm_token` dari dokumen USERS, kirim pesan uji dari
  Firebase Console (Messaging > Send test message).

## 7. Emulator (opsional)

`firebase.json` sudah mengatur emulator Auth (9099) dan Firestore (8080)
beserta file rules. Lihat firestore_rules_testing.md.
