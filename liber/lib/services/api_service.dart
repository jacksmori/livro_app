import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'dart:io';

class ApiService {
  static const String baseUrl =
      'http://192.168.0.2:8000'; // Android emulator -> localhost

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Auth
  static Future<User?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Verifica se a API realmente devolveu um token antes de salvar
        if (data['token'] != null && data['user'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', data['token']);
          return User.fromJson(data['user']);
        } else {
          throw Exception('Resposta inválida do servidor.');
        }
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        // A API recusou o email ou a senha
        throw Exception('Email ou senha inválidos.');
      } else {
        throw Exception('Erro no servidor: ${response.statusCode}');
      }
    } catch (e) {
      // O throw avisa a tela de login que deu erro e qual foi o motivo
      throw Exception('Falha no login: $e');
    }
  }

  static Future<User?> register(String name, String email, String password,
      String confirmPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
        }),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        return User.fromJson(data['user']);
      }
    } catch (_) {}
    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Books
  static Future<List<Book>> getBooks({String? query}) async {
    try {
      final headers = await _headers();
      final url =
          query != null ? '$baseUrl/books?search=$query' : '$baseUrl/books';
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Book.fromJson(e)).toList();
      }
    } catch (_) {}
    return _mockBooks();
  }

  static Future<List<Book>> getFavorites() async {
    try {
      final headers = await _headers();
      final response = await http.get(Uri.parse('$baseUrl/books/favorites'),
          headers: headers);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Book.fromJson(e)).toList();
      }
    } catch (_) {}
    return _mockBooks().where((b) => b.isFavorite).toList();
  }

  static Future<bool> toggleFavorite(int bookId) async {
    try {
      final headers = await _headers();
      final response = await http
          .post(Uri.parse('$baseUrl/books/$bookId/favorite'), headers: headers);
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  static Future<bool> deleteBook(int bookId) async {
    try {
      final headers = await _headers();
      final response = await http.delete(
        Uri.parse('$baseUrl/books/$bookId'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (_) {}
    return true; // modo offline: assume sucesso
  }

  static Future<String?> uploadEpub(File file) async {
    try {
      final token = await getToken();
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      var response = await request.send();
      if (response.statusCode == 200) {
        var reponseBody = await response.stream.bytesToString();
        var data = jsonDecode(reponseBody);
        return data['epub_path'];
      }
    } catch (e) {
      print("Erro no upload do Epub: $e");
    }
    return null;
  }

  static Future<Book?> addBook({
    required String title,
    required String author,
    required String genre,
    required String epubPath,
  }) async {
    try {
      final headers = await _headers();
      final response = await http.post(
        Uri.parse('$baseUrl/books'),
        headers: headers,
        body: jsonEncode({
          'title': title,
          'author': author,
          'genre': genre,
          'content': epubPath,
          'cover_url': '',
        }),
      );
      if (response.statusCode == 201) {
        return Book.fromJson(jsonDecode(response.body));
      }
    } catch (_) {}
    // Fallback mock: cria localmente com id temporário
    final newBook = Book(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      author: author,
      coverUrl: '',
      epubPath: epubPath,
      genre: genre,
    );
    _mockBooks().add(newBook); // não persiste, mas retorna o objeto
    return newBook;
  }

  static Future<bool> updateProgress(int bookId, double progress) async {
    try {
      final headers = await _headers();
      final response = await http.put(
        Uri.parse('$baseUrl/books/$bookId/progress'),
        headers: headers,
        body: jsonEncode({'progress': progress}),
      );
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  // Mock data for offline/demo
  static List<Book> _mockBooks() {
    return [
      Book(
        id: 1,
        title: 'The Silent Forest',
        author: 'Elena Marsh',
        coverUrl: '',
        epubPath: _prologueText(),
        genre: 'Fantasy',
        isFavorite: true,
        progress: 0.35,
      ),
      Book(
        id: 2,
        title: 'Neon Horizons',
        author: 'J. Carvalho',
        coverUrl: '',
        epubPath: _prologueText(),
        genre: 'Sci-Fi',
        isFavorite: false,
        progress: 0.0,
      ),
      Book(
        id: 3,
        title: 'Cartas ao Vento',
        author: 'Ana Lima',
        coverUrl: '',
        epubPath: _prologueText(),
        genre: 'Romance',
        isFavorite: true,
        progress: 0.72,
      ),
      Book(
        id: 4,
        title: 'O Último Mapa',
        author: 'Pedro Santos',
        coverUrl: '',
        epubPath: _prologueText(),
        genre: 'Adventure',
        isFavorite: false,
        progress: 0.1,
      ),
    ];
  }

  static String _prologueText() {
    return '''PROLOGUE

When my parents made me to leave the town I used to live in, I always trusted finally on it. I didn't expect the actually arriving in the village, the stretching trees like a giant brush strokes on our walls. Color was there. But had the flung riding up after a few minutes, finding all the distance and shone between the far trees. But me? None would pass before I was able to end myself back together. Different.

Back I was.

The only one who had disappeared to some of the parking grove, old times hopes there from a trusted condition; nevertheless, yet acting, it was so security and easy until where we settled. The only one entering the door was there or nothing to pass before me to stand with some other tray of homogenous. Head would find the place for me.

When they picked up the pieces, the areas that the continual speakers quartet had for years known me, who had myself forward me, the years there after many times, they would go for this matter a take, eventually started to all resemble.''';
  }
}
