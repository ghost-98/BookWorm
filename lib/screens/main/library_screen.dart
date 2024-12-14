import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LibraryScreen extends StatefulWidget {
  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<dynamic> _libraries = [];
  bool _isLoading = true;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchLibraries();
  }

  Future<void> _loadTokenAndFetchLibraries() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token'); // 저장된 토큰 불러오기

    if (token == null) {
      // 토큰이 없으면 로그인 화면으로 리다이렉트
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    setState(() {
      _token = token; // 토큰 설정
    });

    _fetchLibraries();
  }

  Future<void> _createLibrary(String name, String desc) async {
    final url = 'http://192.168.0.33:5000/library/';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "name": name,
          "desc": desc,
        }),
      );

      if (response.statusCode == 201) {
        _fetchLibraries();
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _fetchLibraries() async {
    final url = 'http://192.168.0.33:5000/library';

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $_token',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _libraries = data['libraries'];
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

  Future<void> _updateLibrary(int libraryId, String newName, String newDesc) async {
    final url = 'http://192.168.0.33:5000/library/$libraryId';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "name": newName,
          "desc": newDesc,
        }),
      );

      if (response.statusCode == 204) {
        _fetchLibraries();
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _deleteLibrary(int libraryId) async {
    final url = 'http://192.168.0.33:5000/library/$libraryId';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 204) {
        _fetchLibraries();
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showCreateLibraryDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("서재 생성"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "이름"),
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: "설명"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("취소"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _createLibrary(nameController.text, descController.text);
              },
              child: Text("생성"),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(int libraryId, String currentName, String currentDesc) {
    final TextEditingController nameController = TextEditingController(text: currentName);
    final TextEditingController descController = TextEditingController(text: currentDesc);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("서재 수정"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "이름"),
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: "설명"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("취소"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updateLibrary(libraryId, nameController.text, descController.text);
              },
              child: Text("저장"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(int libraryId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("삭제 확인"),
          content: Text("이 서재를 삭제하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("취소"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteLibrary(libraryId);
              },
              child: Text("삭제"),
            ),
          ],
        );
      },
    );
  }

  void _onLibraryTap(int libraryId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LibraryBooksScreen(libraryId: libraryId),
      ),
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
          ),
        ),
        backgroundColor: Colors.brown[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: _showCreateLibraryDialog,
            tooltip: "서재 생성",
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _libraries.isEmpty
          ? Center(child: Text('서재가 없습니다.'))
          : ListView.builder(
        itemCount: _libraries.length,
        itemBuilder: (context, index) {
          final library = _libraries[index];
          return ListTile(
            leading: Icon(Icons.library_books, color: Colors.brown[700]),
            title: Text(library['name'] ?? 'Unnamed Library'),
            subtitle: Text(library['desc'] ?? 'No description'),
            onTap: () => _onLibraryTap(library['id']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditDialog(
                    library['id'],
                    library['name'],
                    library['desc'],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirmDialog(library['id']),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LibraryBooksScreen extends StatefulWidget {
  final int libraryId;

  LibraryBooksScreen({required this.libraryId});

  @override
  _LibraryBooksScreenState createState() => _LibraryBooksScreenState();
}

class _LibraryBooksScreenState extends State<LibraryBooksScreen> {
  bool _isLoading = true;
  List<dynamic> _books = [];

  @override
  void initState() {
    super.initState();
    _fetchBooksInLibrary();
  }

  Future<void> _fetchBooksInLibrary() async {
    final url = 'http://192.168.0.33:5000/library/${widget.libraryId}';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _books = data['books'];
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

  Future<void> _deleteBookFromLibrary(int libraryId, int bookId) async {
    final url = 'http://192.168.0.33:5000/library/$libraryId/book/$bookId';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        // 책 삭제 후, 해당 서재의 책 목록을 다시 불러오기
        _fetchBooksInLibrary();
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
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
          ),
        ),
        backgroundColor: Colors.brown[700],
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _books.isEmpty
          ? Center(child: Text('책이 없습니다.'))
          : ListView.builder(
        itemCount: _books.length,
        itemBuilder: (context, index) {
          final book = _books[index];
          return ListTile(
            title: Text(book['title'] ?? 'Unnamed Book'),
            subtitle: Text(book['author'] ?? 'Unknown Author'),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // 책 삭제 요청
                _deleteBookFromLibrary(widget.libraryId, book['id']);
              },
            ),
          );
        },
      ),
    );
  }
}
