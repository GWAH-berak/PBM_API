import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import 'auth_service.dart';

class ProductService {
  static const String baseUrl = 'https://task.itprojects.web.id';

  static Future<Map<String, String>> _headerAutentikasi() async {
    final tokenTersimpan = await AuthService.ambilToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $tokenTersimpan',
    };
  }

  // Ambil item
  static Future<List<ProductModel>> ambilProduk() async {
    final alamatUrl = Uri.parse('$baseUrl/api/products');
    final headerReq = await _headerAutentikasi();

    final responServer = await http.get(alamatUrl, headers: headerReq);
    final dataParsed = jsonDecode(responServer.body);

    if (responServer.statusCode == 200 && dataParsed['success'] == true) {
      final List produkJson = dataParsed['data']['products'];
      return produkJson.map((item) => ProductModel.fromJson(item)).toList();
    }

    throw Exception(dataParsed['message'] ?? 'Gagal memuat produk');
  }

  // Simpan produk baru sebagai draft ke server
  static Future<bool> tambahProduk({
    required String namaProduk,
    required int harga,
    required String deskripsi,
  }) async {
    final alamatUrl = Uri.parse('$baseUrl/api/products');
    final headerReq = await _headerAutentikasi();

    final responServer = await http.post(
      alamatUrl,
      headers: headerReq,
      body: jsonEncode({
        'name': namaProduk,
        'price': harga,
        'description': deskripsi,
      }),
    );

    final dataParsed = jsonDecode(responServer.body);
    return responServer.statusCode == 201 && dataParsed['success'] == true;
  }

  // Hapus produk 
  static Future<bool> hapusProduk(int idProduk) async {
    final alamatUrl = Uri.parse('$baseUrl/api/products/$idProduk');
    final headerReq = await _headerAutentikasi();

    final responServer = await http.delete(alamatUrl, headers: headerReq);
    final dataParsed = jsonDecode(responServer.body);
    return dataParsed['success'] == true;
  }

  static Future<Map<String, dynamic>> kirimTugas({
    required String namaProduk,
    required int harga,
    required String deskripsi,
    required String urlGithub,
  }) async {
    final alamatUrl = Uri.parse('$baseUrl/api/products/submit');
    final headerReq = await _headerAutentikasi();

    final responServer = await http.post(
      alamatUrl,
      headers: headerReq,
      body: jsonEncode({
        'name': namaProduk,
        'price': harga,
        'description': deskripsi,
        'github_url': urlGithub,
      }),
    );

    final dataParsed = jsonDecode(responServer.body);

    if (responServer.statusCode == 201 && dataParsed['success'] == true) {
      return {'success': true, 'message': dataParsed['message']};
    }

    return {
      'success': false,
      'message': dataParsed['message'] ?? 'Submit gagal',
    };
  }
}