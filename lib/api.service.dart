import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class ApiService {
  // Ganti dengan URL API kamu
  static const String baseUrl = "https://learncode.biz.id/api";

  // -----------------------------
  // Helper untuk ambil token
  // -----------------------------
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // -----------------------------
  // LOGIN
  // -----------------------------
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse("$baseUrl/login");

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      final data = jsonDecode(res.body);

      // Jika login sukses → simpan token
      if (res.statusCode == 200 && data["token"] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["token"]);
      }

      return data;

    } catch (e) {
      return {
        "success": false,
        "message": "Gagal terhubung ke server: $e"
      };
    }
  }

  // -----------------------------
  // REGISTER
  // -----------------------------
  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final url = Uri.parse("$baseUrl/register");

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
        }),
      );

      return jsonDecode(res.body);

    } catch (e) {
      return {
        "success": false,
        "message": "Gagal terhubung ke server: $e"
      };
    }
  }

  // -----------------------------
  // GET USER (PAKAI TOKEN)
  // -----------------------------
  Future<Map<String, dynamic>> getUser() async {
    final token = await _getToken();
    final url = Uri.parse("$baseUrl/user");

    try {
      final res = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      return jsonDecode(res.body);

    } catch (e) {
      return {
        "success": false,
        "message": "Gagal mengambil data user: $e"
      };
    }
  }

  // -----------------------------
  // LOGOUT
  // -----------------------------
  Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove("token");
  }
}
