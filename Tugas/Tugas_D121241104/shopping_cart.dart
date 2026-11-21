// Simple Shopping Cart - DartPad

// Fungsi menghitung subtotal satu produk (harga x jumlah)
int hitungSubtotal(int harga, int jumlah) {
  return harga * jumlah;
}

// Fungsi menentukan persentase diskon berdasarkan total belanja
// Ketentuan:
// - Total >= 1.000.000 -> diskon 15%
// - Total >= 500.000   -> diskon 10%
// - Total >= 200.000   -> diskon 5%
// - Di bawah 200.000   -> tidak ada diskon
int tentukanDiskon(int total) {
  if (total >= 1000000) {
    return 15;
  } else if (total >= 500000) {
    return 10;
  } else if (total >= 200000) {
    return 5;
  } else {
    return 0;
  }
}

// Fungsi untuk memformat angka menjadi format Rupiah (contoh: 1500000 -> Rp 1.500.000)
String formatRupiah(num angka) {
  String s = angka.round().toString();
  String hasil = '';
  int hitung = 0;
  for (int i = s.length - 1; i >= 0; i--) {
    hasil = s[i] + hasil;
    hitung++;
    if (hitung % 3 == 0 && i != 0) {
      hasil = '.' + hasil;
    }
  }
  return 'Rp $hasil';
}

void main() {
  // Keranjang belanja: List berisi Map (nama, harga, jumlah)
  List<Map<String, dynamic>> keranjang = [
    {'nama': 'Keyboard', 'harga': 250000, 'jumlah': 1},
    {'nama': 'Mouse', 'harga': 120000, 'jumlah': 2},
    {'nama': 'Flashdisk 64GB', 'harga': 80000, 'jumlah': 3},
    {'nama': 'Headset', 'harga': 175000, 'jumlah': 1},
  ];

  int totalBelanja = 0;

  print('================ SIMPLE SHOPPING CART ================');
  print('No  Produk            Harga        Qty   Subtotal');
  print('------------------------------------------------------');

  // Loop untuk menampilkan setiap produk dan menghitung total
  for (int i = 0; i < keranjang.length; i++) {
    String nama = keranjang[i]['nama'];
    int harga = keranjang[i]['harga'];
    int jumlah = keranjang[i]['jumlah'];

    int subtotal = hitungSubtotal(harga, jumlah);
    totalBelanja += subtotal;

    print(
      '${i + 1}   ${nama.padRight(16)}  ${formatRupiah(harga).padRight(11)}  '
      '${jumlah.toString().padRight(4)}  ${formatRupiah(subtotal)}',
    );
  }

  print('------------------------------------------------------');

  // Hitung diskon
  int persenDiskon = tentukanDiskon(totalBelanja);
  double nilaiDiskon = totalBelanja * persenDiskon / 100;
  double totalBayar = totalBelanja - nilaiDiskon;

  print('Subtotal       : ${formatRupiah(totalBelanja)}');

  if (persenDiskon > 0) {
    print('Diskon ($persenDiskon%)    : -${formatRupiah(nilaiDiskon)}');
    print('Selamat! Kamu mendapatkan diskon $persenDiskon%.');
  } else {
    print('Diskon         : Rp 0');
    print('Belanja minimal Rp 200.000 untuk mendapatkan diskon.');
  }

  print('------------------------------------------------------');
  print('TOTAL BAYAR    : ${formatRupiah(totalBayar)}');
  print('======================================================');
}
