# Pengujian Firestore Security Rules

**Status: aturan belum diuji.** Tabel hasil di bawah sengaja kosong. Isi hanya
setelah pengujian benar-benar dijalankan.

## Ringkasan aturan (`firestore.rules`)

| Koleksi | Baca | Tulis | Hapus |
|---|---|---|---|
| USERS | Pemilik (uid = ID dokumen) | Pemilik | Tidak ada |
| CATS | Pemilik (`owner_id`) | Pemilik; `owner_id` harus uid sendiri | Pemilik |
| MEDICAL_HISTORY | Pemilik (`owner_id`) | Pemilik; `owner_id` harus uid sendiri | Pemilik |
| CARE_RECORD | Pemilik (`owner_id`) | Create saja, tanpa update | Tidak ada |
| SCHEDULE | Pemilik (`owner_id`) | Pemilik; `owner_id` harus uid sendiri | Pemilik |
| Lainnya | Tidak ada | Tidak ada | Tidak ada |

## Cara menjalankan emulator

```bash
npm install -g firebase-tools
firebase emulators:start --only firestore,auth --project demo-catlendar
```

Emulator UI: http://localhost:4000. Nama proyek berawalan `demo-` membuat
emulator berjalan tanpa proyek Firebase sungguhan.

Skenario dapat dijalankan manual lewat Emulator UI, atau otomatis dengan
`@firebase/rules-unit-testing` (belum dibuat di repository ini).

## Skenario uji

Siapkan dua pengguna: **A** dan **B**. Data awal: satu dokumen `CATS` milik A
dan satu milik B; satu dokumen `CARE_RECORD` milik A.

| # | Skenario | Hasil yang diharapkan | Hasil aktual | 14 November 2026|
|---|---|---|---|---|
| 1 | A membaca CATS milik A | Berhasil | belum diuji | |
| 2 | A membaca CATS milik B | Ditolak | belum diuji | |
| 3 | A membuat CATS dengan `owner_id` milik B | Ditolak | belum diuji | |
| 4 | A mengubah `owner_id` CATS miliknya menjadi uid B | Ditolak | belum diuji | |
| 5 | Pengguna tanpa login membaca data apa pun | Ditolak | belum diuji | |
| 6 | A membaca USERS milik B | Ditolak | belum diuji | |
| 7 | A mengubah CARE_RECORD yang sudah ada | Ditolak | belum diuji | |
| 8 | A menghapus USERS miliknya sendiri | Ditolak | belum diuji | |

Skenario tambahan yang disarankan:

| # | Skenario | Hasil yang diharapkan |
|---|---|---|
| 9 | A membuat CARE_RECORD dengan `owner_id` A | Berhasil |
| 10 | A menghapus CARE_RECORD miliknya | Ditolak |
| 11 | A query CATS dengan `where owner_id == uid A` | Berhasil |
| 12 | A query CATS tanpa filter `owner_id` | Ditolak (query tidak aman) |
| 13 | Akses koleksi di luar lima koleksi ERD | Ditolak |

## Catatan

- Skenario 12 menegaskan aturan penting untuk developer: semua query list wajib
  memuat filter `owner_id`.
- Aturan tidak memeriksa kepemilikan `cat_id` pada koleksi anak (lihat
  `docs/architecture.md`, bagian "Hal penting").
