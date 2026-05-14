import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'product_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _kunciForm = GlobalKey<FormState>();
  final _controllerNim = TextEditingController();
  final _controllerSandi = TextEditingController();

  bool _sedangLoading = false;
  bool _sandiTersembunyi = true;

  @override
  void dispose() {
    _controllerNim.dispose();
    _controllerSandi.dispose();
    super.dispose();
  }

  Future<void> _prosesLogin() async {
    if (!_kunciForm.currentState!.validate()) return;

    setState(() => _sedangLoading = true);

    try {
      final hasilLogin = await AuthService.login(
        _controllerNim.text.trim(),
        _controllerSandi.text.trim(),
      );

      if (!mounted) return;

      if (hasilLogin['success'] == true) {
        final dataPengguna = hasilLogin['user'] as UserModel;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ProductScreen(user: dataPengguna)),
        );
      } else {
        _tampilkanError(hasilLogin['message'] ?? 'Login gagal');
      }
    } catch (e) {
      _tampilkanError('Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _sedangLoading = false);
    }
  }

  void _tampilkanError(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _kunciForm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // Header aplikasi
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.shopping_bag, size: 64, color: Colors.blue),
                    const SizedBox(height: 12),
                    const Text(
                      'Katalog Produk',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Masuk menggunakan NIM',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Input NIM sebagai username
              const Text('Username (NIM)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _controllerNim,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Masukkan NIM Anda',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (isiField) =>
                    (isiField == null || isiField.isEmpty)
                        ? 'NIM tidak boleh kosong'
                        : null,
              ),

              const SizedBox(height: 16),

              // Input NIM sebagai password
              const Text('Password (NIM)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _controllerSandi,
                obscureText: _sandiTersembunyi,
                decoration: InputDecoration(
                  hintText: 'Masukkan NIM Anda',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _sandiTersembunyi
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () => setState(
                        () => _sandiTersembunyi = !_sandiTersembunyi),
                  ),
                ),
                validator: (isiField) =>
                    (isiField == null || isiField.isEmpty)
                        ? 'Password tidak boleh kosong'
                        : null,
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sedangLoading ? null : _prosesLogin,
                  child: _sedangLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}