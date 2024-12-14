import 'package:flutter/material.dart';
import 'package:bookworm_fe/services/auth_service.dart';

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
  DateTime? _birthDay;
  final TextEditingController _genderController = TextEditingController();

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
                if (isSuccess) Navigator.pop(context); // 성공 시 화면 뒤로 이동
              },
              child: Text("확인"),
            ),
          ],
        );
      },
    );
  }

  void _register() async {
    final userInfo = {
      "username": _usernameController.text.trim(),
      "password": _passwordController.text.trim(),
      "email": _emailController.text.trim(),
      "name": _nameController.text.trim(),
      "phone_number": _phoneController.text.trim(),
      "birth_day": _birthDay?.toIso8601String() ?? '',
      "gender": _genderController.text.trim(),
    };

    if (userInfo.values.any((field) => field.isEmpty)) {
      _showPopup("입력 오류", "모든 필드를 입력해주세요.", false);
      return;
    }

    final success = await _authService.register(userInfo);

    if (success) {
      _showPopup("회원가입 성공", "회원가입이 성공적으로 완료되었습니다!", true);
    } else {
      _showPopup("회원가입 실패", "회원가입에 실패했습니다. 입력 정보를 확인해주세요.", false);
    }
  }

  void _selectBirthDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _birthDay = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false, // 왼쪽 정렬
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              SizedBox(height: 10),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "이메일",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "이름",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "전화번호",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: _selectBirthDate,
                child: AbsorbPointer(
                  child: TextField(
                    controller: TextEditingController(
                      text: _birthDay == null ? '' : _birthDay!.toLocal().toString().split(' ')[0],
                    ),
                    decoration: InputDecoration(
                      labelText: "생년월일 (YYYY-MM-DD)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _genderController,
                decoration: InputDecoration(
                  labelText: "성별",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: Text("회원가입", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
