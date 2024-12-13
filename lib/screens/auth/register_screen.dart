import 'package:flutter/material.dart';
import 'package:bookworm_fe/services/auth_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthDayController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  final AuthService _authService = AuthService();

  void _register() async {
    final userInfo = {
      "username": _usernameController.text.trim(),
      "password": _passwordController.text.trim(),
      "email": _emailController.text.trim(),
      "name": _nameController.text.trim(),
      "phone_number": _phoneController.text.trim(),
      "birth_day": _birthDayController.text.trim(),
      "gender": _genderController.text.trim(),
    };

    if (userInfo.values.any((field) => field.isEmpty)) {
      Fluttertoast.showToast(msg: "모든 필드를 입력해주세요.");
      return;
    }

    final success = await _authService.register(userInfo);

    if (success) {
      Fluttertoast.showToast(msg: "회원가입 성공");
      Navigator.pop(context); // 로그인 화면으로 돌아가기
    } else {
      Fluttertoast.showToast(msg: "회원가입 실패. 입력 정보를 확인해주세요.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("회원가입"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
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
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "이메일"),
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "이름"),
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "전화번호"),
              ),
              TextField(
                controller: _birthDayController,
                decoration: InputDecoration(labelText: "생년월일 (YYYY-MM-DD)"),
              ),
              TextField(
                controller: _genderController,
                decoration: InputDecoration(labelText: "성별"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: Text("회원가입"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
