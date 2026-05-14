import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/product_service.dart';

class SubmitScreen extends StatefulWidget {
  final UserModel user;
  const SubmitScreen({super.key, required this.user});

  @override
  State<SubmitScreen> createState() => _SubmitScreenState();
}

class _SubmitScreenState extends State<SubmitScreen> {
  final _kunciForm = GlobalKey<FormState>();

  final _controllerNama = TextEditingController();
  final _controllerHarga = TextEditingController();
  final _controllerDeskripsi = TextEditingController();
  final _controllerGithub = TextEditingController();

  bool _sedangLoading = false;
  bool _sudahDikirim = false;

  @override
  void dispose() {
    _controllerNama.dispose();
    _controllerHarga.dispose();
    _controllerDeskripsi.dispose();
    _controllerGithub.dispose();
    super.dispose();
  }

  Future<void> _kirimTugas() async {
    if (!_kunciForm.currentState!.validate()) return;

    setState(() => _sedangLoading = true);

    try {
      final hasilKirim = await ProductService.kirimTugas(
        namaProduk: _controllerNama.text.trim(),
        harga: int.parse(_controllerHarga.text.trim()),
        deskripsi: _controllerDeskripsi.text.trim(),
        urlGithub: _controllerGithub.text.trim(),
      );

      if (!mounted) return;

      if (hasilKirim['success'] == true) {
        setState(() => _sudahDikirim = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hasilKirim['message'] ?? 'Submit gagal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _sedangLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Tugas')),
      body: _sudahDikirim ? _tampilanBerhasil() : _tampilanForm(),
    );
  }

  Widget _tampilanBerhasil() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text(
              'Tugas Berhasil Disubmit!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Data kamu telah tercatat di dashboard asisten praktikum.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali ke Katalog'),
            ),
          ],
        ),
      ),
    );
  }

  // Form untuk mengisi data produk dan link GitHub sebelum submit
  Widget _tampilanForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _kunciForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.blue[50],
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Submit hanya bisa dilakukan sekali. Pastikan data sudah benar!',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text('Nama Produk'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _controllerNama,
              decoration: const InputDecoration(
                hintText: 'Contoh: MacBook Pro M5 2026',
                prefixIcon: Icon(Icons.inventory_2),
                border: OutlineInputBorder(),
              ),
              validator: (isiField) => isiField!.isEmpty ? 'Wajib diisi' : null,
            ),

            const SizedBox(height: 16),

            const Text('Harga (Rp)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _controllerHarga,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Contoh: 32450000',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              validator: (isiField) {
                if (isiField!.isEmpty) return 'Wajib diisi';
                if (int.tryParse(isiField) == null) return 'Harus berupa angka';
                return null;
              },
            ),

            const SizedBox(height: 16),

            const Text('Deskripsi'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _controllerDeskripsi,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Deskripsi produk...',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              validator: (isiField) => isiField!.isEmpty ? 'Wajib diisi' : null,
            ),

            const SizedBox(height: 16),

            const Text('Link Repository GitHub'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _controllerGithub,
              decoration: const InputDecoration(
                hintText: 'https://github.com/username/repo',
                prefixIcon: Icon(Icons.link),
                border: OutlineInputBorder(),
              ),
              validator: (isiField) {
                if (isiField!.isEmpty) return 'Wajib diisi';
                if (!isiField.startsWith('https://github.com/')) {
                  return 'URL GitHub tidak valid';
                }
                return null;
              },
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sedangLoading ? null : _kirimTugas,
                icon: _sedangLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload),
                label: Text(_sedangLoading ? 'Mengirim...' : 'Submit Tugas'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}