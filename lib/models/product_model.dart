// Representasi data produk yang diterima dari server
class ProductModel {
  final int id;
  final String namaProduk;
  final double harga;
  final String deskripsi;
  final String dibuatPada;
  final String diperbaruiPada;

  ProductModel({
    required this.id,
    required this.namaProduk,
    required this.harga,
    required this.deskripsi,
    required this.dibuatPada,
    required this.diperbaruiPada,
  });

  // Buat objek dari data API
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      namaProduk: json['name'],
      harga: double.parse(json['price'].toString()),
      deskripsi: json['description'] ?? '',
      dibuatPada: json['created_at'] ?? '',
      diperbaruiPada: json['updated_at'] ?? '',
    );
  }

  // Gmenampilkan harga dalam format Rupiah
  String get hargaTerformat {
    final hasil = harga.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp $hasil';
  }
}