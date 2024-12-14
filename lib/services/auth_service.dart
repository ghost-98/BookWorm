import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "http://192.168.0.33:5000"; // Flask 서버 주소

  // 로그인 요청
  Future<String?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final accessToken = jsonDecode(response.body)['access_token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken); // 토큰 저장
      return accessToken;
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

  // 로그아웃 시 토큰 삭제
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  // 저장된 토큰 가져오기
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }
}
