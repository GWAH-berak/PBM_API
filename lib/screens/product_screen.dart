import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import 'login_screen.dart';
import 'submit_screen.dart';

class ProductScreen extends StatefulWidget {
  final UserModel user;
  const ProductScreen({super.key, required this.user});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<ProductModel> _daftarProduk = [];
  bool _sedangLoading = true;

  @override
  void initState() {
    super.initState();
    _muatProduk();
  }

  // Ambil data produk dari server
  Future<void> _muatProduk() async {
    setState(() => _sedangLoading = true);
    try {
      final hasilProduk = await ProductService.ambilProduk();
      setState(() => _daftarProduk = hasilProduk);
    } catch (e) {
      _tampilkanSnack('Gagal memuat produk: $e', isError: true);
    } finally {
      setState(() => _sedangLoading = false);
    }
  }

  void _tampilkanSnack(String pesan, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _tampilkanDialogTambah() async {
    final controllerNama = TextEditingController();
    final controllerHarga = TextEditingController();
    final controllerDeskripsi = TextEditingController();
    final kunciForm = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Produk'),
        content: SingleChildScrollView(
          child: Form(
            key: kunciForm,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: controllerNama,
                  decoration: const InputDecoration(
                    labelText: 'Nama Produk',
                    border: OutlineInputBorder(),
                  ),
                  validator: (isiField) =>
                      isiField!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: controllerHarga,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga (Rp)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (isiField) {
                    if (isiField!.isEmpty) return 'Wajib diisi';
                    if (int.tryParse(isiField) == null) {
                      return 'Harus berupa angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: controllerDeskripsi,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                  validator: (isiField) =>
                      isiField!.isEmpty ? 'Wajib diisi' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!kunciForm.currentState!.validate()) return;

              final berhasil = await ProductService.tambahProduk(
                namaProduk: controllerNama.text.trim(),
                harga: int.parse(controllerHarga.text.trim()),
                deskripsi: controllerDeskripsi.text.trim(),
              );

              if (ctx.mounted) Navigator.pop(ctx);

              if (berhasil) {
                _tampilkanSnack('Produk berhasil ditambahkan!');
                _muatProduk();
              } else {
                _tampilkanSnack('Gagal menambahkan produk', isError: true);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // Hapus produk 
  Future<void> _hapusProduk(ProductModel produkDipilih) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus "${produkDipilih.namaProduk}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      final berhasil = await ProductService.hapusProduk(produkDipilih.id);
      if (berhasil) {
        _tampilkanSnack('Produk dihapus');
        _muatProduk();
      } else {
        _tampilkanSnack('Gagal menghapus produk', isError: true);
      }
    }
  }

  // Hapus token 
  Future<void> _keluarAkun() async {
    await AuthService.hapusToken();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Submit Tugas',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SubmitScreen(user: widget.user),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _keluarAkun,
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner info 
          Container(
            width: double.infinity,
            color: Colors.blue[50],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.account_circle, color: Colors.blue),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.nama,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${widget.user.kelasPengguna.nama} · ${_daftarProduk.length} produk',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: _sedangLoading
                ? const Center(child: CircularProgressIndicator())
                : _daftarProduk.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox, size: 64, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('Belum ada produk'),
                            Text(
                              'Tap + untuk menambahkan produk',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _muatProduk,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _daftarProduk.length,
                          itemBuilder: (_, i) => _KartuProduk(
                            produk: _daftarProduk[i],
                            onHapus: () => _hapusProduk(_daftarProduk[i]),
                          ),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tampilkanDialogTambah,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Card untuk item produk
class _KartuProduk extends StatelessWidget {
  final ProductModel produk;
  final VoidCallback onHapus;

  const _KartuProduk({required this.produk, required this.onHapus});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.shopping_cart, color: Colors.blue),
        title: Text(
          produk.namaProduk,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              produk.hargaTerformat,
              style: const TextStyle(color: Colors.blue),
            ),
            if (produk.deskripsi.isNotEmpty)
              Text(
                produk.deskripsi,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onHapus,
        ),
        isThreeLine: true,
      ),
    );
  }
}