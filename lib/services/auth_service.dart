import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class AuthService {
  static const String baseUrl = 'https://task.itprojects.web.id';

  // Gunakan flutter_secure_storage agar token tersimpan dengan aman
  static const _penyimpanan = FlutterSecureStorage();
  static const _kunciToken = 'auth_token';

  static Future<void> simpanToken(String token) async {
    await _penyimpanan.write(key: _kunciToken, value: token);
  }

  static Future<String?> ambilToken() async {
    return await _penyimpanan.read(key: _kunciToken);
  }

  static Future<void> hapusToken() async {
    await _penyimpanan.delete(key: _kunciToken);
  }

  static Future<Map<String, dynamic>> login(
    String namaUser,
    String katasandi,
  ) async {
    final alamatUrl = Uri.parse('$baseUrl/api/auth/login');

    final responServer = await http.post(
      alamatUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'username': namaUser, 'password': katasandi}),
    );

    final dataParsed = jsonDecode(responServer.body);

    if (responServer.statusCode == 200 && dataParsed['success'] == true) {
      final tokenBaru = dataParsed['data']['token'] as String;
      await simpanToken(tokenBaru);
      final dataPengguna = UserModel.fromJson(dataParsed['data']['user']);
      return {'success': true, 'token': tokenBaru, 'user': dataPengguna};
    }

    return {
      'success': false,
      'message': dataParsed['message'] ?? 'Login gagal',
    };
  }
}