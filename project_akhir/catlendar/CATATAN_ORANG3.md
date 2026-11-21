# Catatan Orang 3: Jadwal, Pengingat, Kalender, Summary

Cakupan: `lib/features/care/` (layar 17 sampai 20), sesuai `docs/panduan_tim.md`.
Layar yang disentuh di luar folder ini hanya yang wajib, dan sudah disebut di bawah.

## Cara menjalankan (terminal)

Prasyarat: Flutter SDK stable, Android Studio atau emulator Android dengan
Google Play, dan `flutter doctor` tanpa error untuk Android.

```bash
cd catlendar                 # folder project ini
flutter pub get              # wajib setelah unzip (pubspec berubah: timezone)
flutter analyze              # harus bersih
flutter test                 # harus lulus
flutter run                  # pilih perangkat bila ditanya
```

Mulai dari Dev Menu (untuk membuka layar langsung):

```bash
flutter run --dart-define=DEV_MENU=true
```

Jika ada `env.json`, tambahkan `--dart-define-from-file=env.json`.
Tanpa file itu, aplikasi memakai nilai bawaan (termasuk API key TheCatAPI).

Uji notifikasi lokal wajib di perangkat Android nyata (OI-04), bukan hanya emulator.

## Pemetaan ke dokumen

| Dokumen | Yang dipenuhi di bagian ini |
|---|---|
| ERD v3 | SCHEDULE (semua kolom), CARE_RECORD (log, create saja), relasi lewat cat_id dan owner_id |
| DFD Level 1 | Proses 5.0 Kelola Jadwal Perawatan dan 6.0 Kirim Pengingat, data store D4 dan D5 |
| BRD v0.2 | BR-07, BR-08, BR-09, BR-11, BR-13, BR-14, FR-33 sampai FR-53, FR-59 sampai FR-64, FR-70 sampai FR-73 |
| Alur 5.3 | Layar 17 (grooming details), 18 (schedule), 19 (calendar), 20 (summary) |
| MR-04 dan MR-05 | Local notification terjadwal, Holiday Indonesia API |

## Keputusan yang diambil (perlu dicek tim)

1. **Status jadwal.** BRD (FR-44, RULE-09) meminta status scheduled, completed,
   cancelled. ERD hanya punya `is_active`. Implementasi memakai `is_active`:
   - scheduled: `is_active = true`
   - completed: `is_active = false`, dan ada baris CARE_RECORD dengan tanggal jadwal
   - cancelled: `is_active = false`, tanpa CARE_RECORD

   Akibatnya completed dan cancelled tidak bisa dibedakan dari data. Ini perlu
   keputusan tim: tambah field `status` di ERD, atau terima kondisi ini.
2. **Jam pengingat: 08.00** waktu perangkat pada hari (next_date dikurangi pilihan hari).
   Asumsi, belum ada di dokumen desain. Pengingat yang waktunya sudah lewat tidak dijadwalkan.
3. **Tanggal jadwal.** Tidak boleh sebelum hari ini (rekomendasi OI-05) dan tidak boleh
   sebelum tanggal terakhir (ERD). Jadwal yang lewat tetap `is_active = true` dan
   ditandai "Terlewat" di Summary dan kalender.
4. **Pemetaan ID notifikasi.** `local_notification_id` (string di ERD) berisi int acak
   unik yang dipakai langsung sebagai id plugin. Tidak ada tabel pemetaan.
5. **Waktu.** Notifikasi dijadwalkan lewat instan UTC (`TZDateTime` dengan zona UTC),
   jadi waktunya benar di zona mana pun. Paket `timezone` ditambahkan ke pubspec.
6. **Riwayat terakhir.** `getLatestRecord` mengurutkan di Dart, tanpa `orderBy`,
   sehingga tidak perlu composite index.
7. **Cache hari libur.** Hanya cache di memori selama sesi (provider Riverpod).
   FR-63 meminta penyimpanan di perangkat. Itu belum dikerjakan (perlu paket
   penyimpanan lokal, dan keputusan tim).
8. **Holiday API.** `https://indonesian-holidays.ahrulsyamil.com`, endpoint
   `/holidays/:year`, field `data[].date`, `name`, `is_national`. Sesuai README
   sumber (MIT). Belum diuji terhadap tahun 2027 (OI-01). Penggunaan hosting milik
   pihak lain perlu dikonfirmasi dosen (OI-02).

## Berkas di luar folder fitur (dibaca dulu oleh tim)

- `pubspec.yaml`: tambah `timezone: ^0.11.2` (sudah ada sebagai transitive di lock).
- `lib/core/constants/app_constants.dart`: isi `holidayApiBaseUrl` (bagian TODO Orang 3).
- `lib/core/notifications/local_notification_service.dart`: implementasi (file ini
  ditandai milik Orang 3 di komentarnya). Kontrak ditambah `requestPermission` dan
  `newNotificationId`.

Tidak diubah: auth, cats, router, Security Rules, FCM.

## Belum dikerjakan

- Push FCM otomatis (tidak termasuk versi ini, sesuai BRD 5.15).
- Tandai selesai dan batalkan dilakukan dari kalender dan Summary, bukan dari
  layar desain. Tidak ada layar khusus di desain Figma.
- Layar 17 dan 18 memakai Continue dan Save sesuai desain. Pilihan pengingat berlaku
  untuk semua jadwal di layar 18.

## Status verifikasi

Kode ini ditulis tanpa Flutter SDK di lingkungan pembuatan, sehingga belum pernah
di-compile atau dijalankan. Jalankan `flutter analyze` dan `flutter test` dulu,
lalu uji alur: buat jadwal dengan pengingat, ubah, selesaikan, batalkan, hapus,
dan cek notifikasi di perangkat nyata.
