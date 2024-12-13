import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://127.0.0.1:5000"; // Flask 서버 주소

  // 로그인 요청
  Future<String?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['access_token'];
    }
    return null;
  }

  // 회원가입 요청
  Future<bool> register(Map<String, dynamic> userInfo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userInfo),
    );

    return response.statusCode == 201;
  }
}
