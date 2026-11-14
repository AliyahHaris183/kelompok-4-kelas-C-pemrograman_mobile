# Pengujian Firestore Security Rules

File aturan: `firestore.rules` di root proyek.

Aturan hanya boleh dianggap teruji setelah semua skenario di bawah dijalankan
dan hasilnya dicatat. Ganti setiap `(isi)` dengan hasil sebenarnya. Jangan
mengisi hasil yang belum diuji.

## Ringkasan aturan

USERS:

- Baca dan tulis: hanya pemilik (uid sama dengan ID dokumen)
- Hapus: tidak ada yang boleh

CATS, MEDICAL_HISTORY, SCHEDULE:

- Baca dan hapus: hanya pemilik (`owner_id` sama dengan uid)
- Buat: `owner_id` harus uid sendiri
- Ubah: pemilik, dan `owner_id` tidak boleh diubah ke uid lain

CARE_RECORD (log):

- Baca: hanya pemilik
- Buat: `owner_id` harus uid sendiri
- Ubah dan hapus: tidak ada yang boleh

Koleksi lain: semua akses ditolak.

## Cara menguji

### Opsi 1: Rules Playground (tanpa kode)

1. Buka Firebase Console, Firestore Database, tab Rules, lalu Rules Playground.
2. Siapkan data uji lewat tab Data (cara ini melewati rules, jadi aman):
   - `CATS/cat-a` dengan field `owner_id` bernilai `uid-A`
   - `CATS/cat-b` dengan field `owner_id` bernilai `uid-B`
   - `CARE_RECORD/cr-a` dengan field `owner_id` bernilai `uid-A`
3. Jalankan tiap skenario di bawah. Atur Simulation type, Location, dan
   Authenticated sesuai skenario.
4. Setelah selesai, hapus ketiga dokumen uji.

Playground hanya menguji aturan, bukan query dari aplikasi.

### Opsi 2: Emulator

```powershell
npm install -g firebase-tools
firebase emulators:start --only firestore,auth --project demo-catlendar
```

Emulator UI ada di http://localhost:4000. Nama proyek berawalan `demo-`
membuat emulator berjalan tanpa proyek Firebase sungguhan.

## Skenario wajib

Pengguna A memakai uid `uid-A`. Pengguna B memakai uid `uid-B`.

### 1. A membaca CATS milik A

- Simulation: get, path `/CATS/cat-a`, login sebagai A
- Diharapkan: Allowed
- Hasil: Allowed
- Tanggal uji: 14-11-2026

### 2. A membaca CATS milik B

- Simulation: get, path `/CATS/cat-b`, login sebagai A
- Diharapkan: Denied
- Hasil: Denied
- Tanggal uji: 14-11-2026

### 3. A membuat CATS dengan owner_id milik B

- Simulation: create, path `/CATS/baru`, login sebagai A, data `owner_id` = `uid-B`
- Diharapkan: Denied
- Hasil: Denied
- Tanggal uji: 14-11-2026

### 4. A mengubah owner_id CATS miliknya menjadi uid B

- Simulation: update, path `/CATS/cat-a`, login sebagai A, data `owner_id` = `uid-B`
- Diharapkan: Denied
- Hasil: Denied
- Tanggal uji: 14-11-2026

### 5. Pengguna tanpa login membaca data

- Simulation: get, path `/CATS/cat-a`, tanpa login
- Diharapkan: Denied
- Hasil: Denied
- Tanggal uji: 14-11-2026

### 6. A membaca USERS milik B

- Simulation: get, path `/USERS/uid-B`, login sebagai A
- Diharapkan: Denied
- Hasil: Denied
- Tanggal uji: 14-11-2026

### 7. A mengubah CARE_RECORD yang sudah ada

- Simulation: update, path `/CARE_RECORD/cr-a`, login sebagai A, data `owner_id` = `uid-A`
- Diharapkan: Denied
- Hasil: Denied
- Tanggal uji: 14-11-2026

### 8. A menghapus USERS miliknya sendiri

- Simulation: delete, path `/USERS/uid-A`, login sebagai A
- Diharapkan: Denied
- Hasil: Denied
- Tanggal uji: 14-11-2026

## Skenario tambahan (disarankan)

Skenario 9 sampai 11 bisa diuji di Playground. Skenario 12 dan 13 paling mudah
diuji lewat aplikasi atau emulator.

### 9. A membuat CARE_RECORD dengan owner_id A

- Diharapkan: Allowed
- Hasil: (isi)

### 10. A menghapus CARE_RECORD miliknya

- Diharapkan: Denied
- Hasil: (isi)

### 11. A mengubah owner_id SCHEDULE miliknya menjadi uid B

- Diharapkan: Denied
- Hasil: (isi)

### 12. A menjalankan query CATS tanpa filter owner_id

- Diharapkan: Denied (query tidak aman)
- Hasil: (isi)

### 13. Akses koleksi di luar lima koleksi ERD

- Diharapkan: Denied
- Hasil: (isi)

## Catatan

- Skenario 12 menegaskan aturan penting untuk developer: semua query list
  wajib memuat filter `owner_id`. Skenario ini baru terbukti penuh setelah
  fitur Orang 2 dan Orang 3 berjalan.
- Aturan tidak memeriksa bahwa `cat_id` pada koleksi anak milik pengguna yang
  sama (lihat `docs/architecture.md`, bagian "Hal penting").
- Jika `firestore.rules` diubah, deploy ulang dan ulangi semua skenario.
