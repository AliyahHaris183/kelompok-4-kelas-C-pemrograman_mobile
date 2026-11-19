// Simple Shopping Cart

// Class sederhana untuk menyimpan data satu produk
class Product {
  final String name; // nama produk
  final int price; // harga satuan (rupiah)
  final int quantity; // jumlah pembelian

  const Product(this.name, this.price, this.quantity);

  // Subtotal per produk = harga x jumlah
  int get subtotal => price * quantity;
}

// Mengubah angka menjadi format rupiah, contoh: 1500000 -> Rp1.500.000
String formatRupiah(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();

  for (int i = 0; i < digits.length; i++) {
    // Beri titik setiap 3 digit dari belakang
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[i]);
  }
  return 'Rp$buffer';
}

// Menjumlahkan subtotal semua produk di keranjang
int calculateSubtotal(List<Product> cart) {
  int total = 0;
  for (final item in cart) {
    total += item.subtotal;
  }
  return total;
}

// Menentukan persentase diskon berdasarkan subtotal:
// >= Rp500.000 -> 10%, >= Rp200.000 -> 5%, selain itu tidak ada diskon
double getDiscountRate(int subtotal) {
  if (subtotal >= 500000) {
    return 0.10;
  } else if (subtotal >= 200000) {
    return 0.05;
  } else {
    return 0.0;
  }
}

// Menghitung nominal diskon
int calculateDiscount(int subtotal, double rate) {
  return (subtotal * rate).round();
}

void main() {
  // Daftar produk di keranjang
  final List<Product> cart = [
    const Product('Buku Tulis', 5000, 10),
    const Product('Pulpen', 3500, 12),
    const Product('Tas Ransel', 185000, 1),
    const Product('Botol Minum', 45000, 2),
  ];

  // Perhitungan
  final int subtotal = calculateSubtotal(cart);
  final double discountRate = getDiscountRate(subtotal);
  final int discount = calculateDiscount(subtotal, discountRate);
  final int total = subtotal - discount;

  // Tampilkan daftar produk
  print('========== SIMPLE SHOPPING CART ==========');
  print('No  Produk          Harga         Jml  Subtotal');
  print('------------------------------------------');

  for (int i = 0; i < cart.length; i++) {
    final item = cart[i];
    final no = (i + 1).toString().padRight(4);
    final name = item.name.padRight(16);
    final price = formatRupiah(item.price).padRight(14);
    final qty = item.quantity.toString().padRight(5);
    print('$no$name$price$qty${formatRupiah(item.subtotal)}');
  }

  print('------------------------------------------');
  print('Subtotal    : ${formatRupiah(subtotal)}');

  // Tampilkan info diskon sesuai kondisi
  if (discountRate > 0) {
    final percent = (discountRate * 100).round();
    print('Diskon ($percent%) : -${formatRupiah(discount)}');
  } else {
    print('Diskon      : tidak ada');
  }

  print('Total Bayar : ${formatRupiah(total)}');
  print('==========================================');
}