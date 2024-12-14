import 'package:flutter/material.dart';
import 'barcode_scanner_screen.dart';
import 'book_search_screen.dart';
import 'library_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 네비게이션 바에서 보여줄 화면들
  final List<Widget> _screens = [
    BarcodeScannerScreen(),
    BookSearchScreen(),
    LibraryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // 현재 선택된 화면
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: '바코드'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '책 검색'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: '내 서재'),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.brown[700],
      ),
    );
  }
}
