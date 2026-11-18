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

## Foto profil (Cloudinary)

Foto profil diambil dari galeri dan diunggah ke Cloudinary (Firebase Storage
tidak dipakai karena butuh billing). URL hasil unggah disimpan di
`USERS.avatar_id`, yang kini bisa berisi **id avatar preset** (mis. `owner_1`)
**atau URL foto** (`https://...`). Tampilkan dengan `AvatarImage`
(`lib/shared/widgets/avatar_image.dart`), yang mengenali keduanya.

Konfigurasi, di `env.json` masing-masing (jangan di-commit):

```json
{
  "CLOUDINARY_CLOUD_NAME": "isi-cloud-name",
  "CLOUDINARY_UPLOAD_PRESET": "isi-upload-preset"
}
```

- Upload preset di dashboard Cloudinary harus bertipe **Unsigned**.
- Batasi preset (format gambar, ukuran maksimum, folder) agar tidak
  disalahgunakan, karena nama cloud dan preset ikut tertanam di aplikasi.
- Paket `image_picker` dibutuhkan. Jika belum ada di `pubspec.yaml`, jalankan
  `flutter pub add image_picker`.
- Unggah memakai `imageUploaderProvider` (`core/providers/media_providers.dart`).
  Fitur lain yang butuh unggah foto (mis. foto kucing) memakai provider yang
  sama, bukan membuat pengunggah sendiri.
- Gambar yang sudah diunggah tidak ikut terhapus bila pengguna mengganti foto.
  Itu batasan unggah tanpa tanda tangan (unsigned).

## Holiday Indonesia API (Orang 3)

Belum diputuskan. Setelah tim memilih API-nya:

1. Isi `AppConstants.holidayApiBaseUrl`.
2. Jika API butuh key, tambahkan `HOLIDAY_API_KEY` di `env.example.json` dan
   `AppConstants`.
3. Implementasikan `HolidayApiDataSource` dan `Holiday.fromJson`.

## Push notification (FCM)

Token FCM perangkat disimpan otomatis di dokumen USERS (`fcm_token`) setiap
akun yang lengkap membuka aplikasi, diperbarui saat FCM mengganti token, dan
dihapus saat log out. Tidak ada yang perlu dilakukan di layar mana pun.

Syarat untuk menguji di Android:

- Emulator harus memakai system image **Google Play** atau **Google APIs**.
  Emulator tanpa Google Play Services tidak bisa menerima FCM.
- `AndroidManifest.xml` memuat izin notifikasi (Android 13 ke atas):
  `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>`
- Saat pertama kali masuk, izinkan notifikasi pada dialog yang muncul.

Cara mengirim push uji:

1. Login di aplikasi, lalu buka dokumen `USERS/{uid}` di Firebase Console dan
   salin nilai `fcm_token`.
2. Firebase Console, Messaging, Create your first campaign (atau New campaign),
   pilih Firebase Notification messages, lalu Send test message.
3. Tempel token tadi, lalu Test.
4. **Minimalkan aplikasi** (tekan tombol Home) sebelum mengirim. Pesan yang
   dikirim saat aplikasi sedang terbuka tidak tampil otomatis di Android.
   Notifikasi akan muncul di status bar.

Pengiriman otomatis dari server butuh Cloud Functions, yang tidak dipakai.

## Notifikasi terjadwal (Orang 3)

- Setup Android untuk `flutter_local_notifications` mengikuti dokumentasi paket
  tersebut.
- Notifikasi terjadwal butuh paket `timezone`: `flutter pub add timezone`.

## Masalah umum

- **Banner merah "Firebase belum terkonfigurasi":** baris di bawah banner
  berisi penyebabnya. Kirim ke Orang 1.
- **Build Android gagal soal `minSdkVersion`:** ubah `minSdk` menjadi 23 di
  `android/app/build.gradle` (atau `build.gradle.kts`).
- **Breed tidak muncul:** jalankan dengan `--dart-define-from-file=env.json`.
