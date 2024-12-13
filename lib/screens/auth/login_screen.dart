import 'package:flutter/material.dart';
import 'package:bookworm_fe/screens/auth/register_screen.dart';
import 'package:bookworm_fe/screens/main/main_screen.dart';
import 'package:bookworm_fe/services/auth_service.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _showPopup(String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(color: isSuccess ? Colors.green : Colors.red)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (isSuccess) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MainScreen()), // 홈 화면으로 이동
                  );                }
              },
              child: Text("확인"),
            ),
          ],
        );
      },
    );
  }

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      print('Error: Missing username or password');
      _showPopup("입력 오류", "아이디와 비밀번호를 입력해주세요.", false);
      return;
    }
    print('Attempting login with username: $username');
    final token = await _authService.login(username, password);

    if (token != null) {
      print('Login successful. Token: $token');
      _showPopup("로그인 성공", "환영합니다!", true);
    } else {
      _showPopup("로그인 실패", "아이디와 비밀번호를 확인해주세요.", false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "Bookworm",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Roboto', // 원하는 폰트를 추가하세요.
          ),
        ),
        backgroundColor: Colors.brown[700],
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("로그인", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: "아이디",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: "비밀번호",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text("로그인", style: TextStyle(fontSize: 16)),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: Text("계정이 없으신가요? 회원가입"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
