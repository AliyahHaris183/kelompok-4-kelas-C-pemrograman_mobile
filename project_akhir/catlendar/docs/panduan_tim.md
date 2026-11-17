# Panduan Kerja Tim

Dokumen ini menjelaskan siapa mengerjakan apa dan bagaimana menggabungkan
pekerjaan tiga orang tanpa saling menimpa.

## Siapa mengedit apa

Setiap anggota hanya mengedit folder fiturnya sendiri.

- Orang 1: `lib/features/auth/`
- Orang 2: `lib/features/cats/`
- Orang 3: `lib/features/care/`

Folder berikut adalah milik bersama. Jangan diubah sendiri-sendiri. Beri tahu
tim di grup dan buka pull request yang direview oleh minimal satu orang lain:

- `lib/core/`
- `lib/shared/`
- `lib/app/`
- model di `data/models/` (karena mengikuti ERD)
- `firestore.rules`
- `pubspec.yaml`

## Layar milik masing-masing

Nomor layar mengikuti dokumen alur aplikasi (bagian 5).

Orang 1, Auth dan Settings:

- Layar 1 sampai 11: Hello, Welcome, Log in, Forgot password, Sign up, Create
  password, Verifikasi email, Greeting, Set up profile, Date of birth,
  Ringkasan profil
- Layar 21 sampai 24: Settings, Edit profile, Change password, Log out
- Log out adalah dialog konfirmasi di Settings, bukan file layar terpisah.

Orang 2, Cats dan Home:

- Layar 12 sampai 16: Add your first cat, Ringkasan kucing, Home, Profil
  kucing, Edit profil kucing

Orang 3, Care:

- Layar 17 sampai 20: Grooming history, Schedule setup, Calendar, Summary

## Alur git

- Satu branch per orang: `feature/auth`, `feature/cats`, `feature/care`.
- Jangan commit langsung ke `main`. Gabungkan lewat Pull Request, direview
  minimal satu orang lain.
- Ambil perubahan terbaru dari `main` ke branch sendiri secara rutin, minimal
  sekali sehari, agar konflik tidak menumpuk.

## Sebelum membuka pull request

Centang semuanya:

- `flutter analyze` bersih (tanpa error, warning, maupun info)
- `flutter test` lulus
- Aplikasi bisa dijalankan dan layar Anda bisa dibuka
- Tidak ada file rahasia yang ikut (`env.json`, kunci, dan sejenisnya)
- Perubahan hanya di folder fitur Anda, atau sudah disepakati tim

## File yang sering bentrok

Tiga file ini disentuh banyak orang, jadi paling rawan konflik git:

- `lib/app/router/app_router.dart` dan `app_routes.dart`: setiap rute baru
  ditambah di sini. Tambahkan di akhir bagian fitur Anda, jangan menata ulang.
- `pubspec.yaml`: setiap paket baru. Setelah merge, semua anggota menjalankan
  `flutter pub get`.
- `firestore.rules`: perubahan harus disepakati tim lalu di-deploy ulang.

Jika terjadi konflik, selesaikan bersama orang yang mengubah file yang sama,
jangan memilih salah satu secara asal.

## Aturan penting saat menulis kode

1. Jangan memanggil `FirebaseFirestore.instance` atau `FirebaseAuth.instance`
   langsung. Pakai provider di `lib/core/providers/firebase_providers.dart`.
2. Jangan menulis nama koleksi atau field sebagai string. Pakai
   `FirestoreCollections` dan `FirestoreFields` di `lib/core/constants/`.
3. Semua query list wajib memuat filter `owner_id`. Tanpa itu, Firestore
   menolak query karena Security Rules memeriksa `owner_id`.
4. `CARE_RECORD` adalah log. Jangan membuat fungsi update atau delete untuknya.
5. Layar hanya membaca state dan memanggil method controller. Tidak ada
   panggilan Firestore atau Firebase Auth di dalam layar.
6. Jangan menambah package state management lain selain Riverpod.
7. Jangan menambah field atau entitas di luar ERD tanpa kesepakatan tim.
8. Jangan menaruh API key atau kredensial di kode atau git.

## Urutan kerja yang disarankan

Orang 2 dan Orang 3 membaca `owner_id` dari pengguna yang sedang login, dan itu
baru berfungsi penuh setelah Auth (Orang 1) selesai.

- Awal: semua mengerjakan repository dan UI di folder masing-masing.
- Untuk menguji dengan data sungguhan sebelum Auth selesai, buat satu akun
  uji lewat Firebase Console (Authentication, tab Users, Add user).
- Setelah Login dan Sign up selesai: uji alur dari awal sampai akhir bersama.

## Cara menambah rute baru

1. Tambah konstanta `AppRoute` di `lib/app/router/app_routes.dart`.
2. Tambah `_route(...)` di `lib/app/router/app_router.dart`.
3. Jika rute berparameter, taruh yang lebih spesifik sebelum yang berparameter
   (contoh: `/cats/add` harus sebelum `/cats/:catId`).

## Cara menambah dependency

Jalankan `flutter pub add nama_paket`, lalu beri tahu tim di grup. Setelah
merge, semua menjalankan `flutter pub get`.
