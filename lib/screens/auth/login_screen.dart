import 'package:flutter/material.dart';
import 'package:bookworm_fe/screens/auth/register_screen.dart';
import 'package:bookworm_fe/services/auth_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: "아이디와 비밀번호를 입력해주세요.");
      return;
    }

    final token = await _authService.login(username, password);

    if (token != null) {
      Fluttertoast.showToast(msg: "로그인 성공");
      // 홈 화면으로 이동 로직 추가 (추후 구현)
    } else {
      Fluttertoast.showToast(msg: "로그인 실패. 아이디와 비밀번호를 확인해주세요.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("로그인"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "아이디"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "비밀번호"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text("로그인"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text("계정이 없으신가요? 회원가입"),
            ),
          ],
        ),
      ),
    );
  }
}
