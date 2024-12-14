import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BookSearchScreen extends StatefulWidget {
  @override
  _BookSearchScreenState createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends State<BookSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _books = [];
  List<dynamic> _libraries = []; // 서재 리스트
  bool _isLoading = false;

  final String nationalLibraryApiUrl = "https://www.nl.go.kr/seoji/SearchApi.do";
  final String apiKey = "07ff4cf12b7e16a21a51c79cd644b51a855b53a43baace93eb3983d9d8556c09";
  final String libraryApiUrl = "http://192.168.0.33:5000/library/"; // Flask 서재 API
  final String addBookApiUrl = "http://192.168.0.33:5000/library/add_book"; // 도서 추가 API

  // SharedPreferences에서 access_token 가져오기
  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // 도서 검색
  Future<void> _searchBooks(String keyword) async {
    final encodedKeyword = Uri.encodeComponent(keyword); // 한글을 URL 인코딩

    final url =
        '$nationalLibraryApiUrl?cert_key=$apiKey&result_style=json&page_no=1&page_size=10&start_publish_date=19800101&end_publish_date=20241212&title=$encodedKeyword';

    try {
      setState(() {
        _isLoading = true;
      });

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 중복 제거
        final uniqueBooks = (data['docs'] as List<dynamic>)
            .map((book) => book as Map<String, dynamic>)
            .toSet()
            .toList();

        setState(() {
          _books = uniqueBooks;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
    }
  }

  // 서재 리스트 가져오기
  Future<void> _fetchLibraries() async {
    final token = await _getAccessToken();
    if (token == null) {
      print("Access token not found");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(libraryApiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 서버 응답에서 'libraries' 키가 있는지 확인
        if (data != null && data['libraries'] != null) {
          setState(() {
            _libraries = data['libraries'];
          });
        } else {
          setState(() {
            _libraries = [];
          });
          print('No libraries found in response.');
        }
      } else {
        setState(() {
          _libraries = [];
        });
        print('Error fetching libraries: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _libraries = [];
      });
      print('Error: $e');
    }
  }

  // 서재에 도서 추가
  Future<void> _addBookToLibrary(int libraryId, Map<String, dynamic> book) async {
    final token = await _getAccessToken();
    if (token == null) {
      print("Access token not found");
      return;
    }

    final body = json.encode({
      "library_id": libraryId,
      "title": book['TITLE'] ?? "제목 없음",
      "author": book['AUTHOR'] ?? "저자 없음",
      "publisher": book['PUBLISHER'] ?? "출판사 없음",
      "page": book['PAGE'],
      "ISBN": book['EA_ISBN'] ?? "ISBN 없음",
      "image": book['IMAGE_URL'] ?? "",
    });

    try {
      final response = await http.post(
        Uri.parse(addBookApiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("서재에 도서가 추가되었습니다!")),
        );
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // 서재 선택 팝업
  void _showLibrarySelectionDialog(Map<String, dynamic> book) async {
    await _fetchLibraries(); // 서재 리스트 가져오기

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("서재 선택"),
          content: _libraries.isEmpty
              ? Text("등록된 서재가 없습니다.")
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: _libraries.map((library) {
              return ListTile(
                title: Text(library['name']),
                onTap: () {
                  Navigator.pop(context); // 팝업 닫기
                  _addBookToLibrary(library['id'], book); // 도서 추가
                },
              );
            }).toList(),
          ),
        );
      },
    );
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
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: Colors.brown[700],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: '책 제목 검색',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    if (_searchController.text.trim().isNotEmpty) {
                      _searchBooks(_searchController.text.trim());
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
              child: _books.isEmpty
                  ? Center(child: Text('검색 결과가 없습니다.'))
                  : ListView.builder(
                itemCount: _books.length,
                itemBuilder: (context, index) {
                  final book = _books[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 8.0,
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book['TITLE'] ?? '제목 없음',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Text(
                            '저자: ${book['AUTHOR'] ?? '저자 없음'}',
                            style: TextStyle(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Text(
                            '출판사: ${book['PUBLISHER'] ?? '출판사 없음'}',
                            style: TextStyle(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Text(
                            '페이지: ${book['PAGE'] ?? '정보 없음'}',
                            style: TextStyle(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'ISBN: ${book['EA_ISBN'] ?? '정보 없음'}',
                            style: TextStyle(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton(
                              onPressed: () {
                                _showLibrarySelectionDialog(book);
                              },
                              child: Text("서재 추가"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
