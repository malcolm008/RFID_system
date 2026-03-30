import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000/attendance_api';

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  late final http.Client _client;

  void _initClient() {
    _client = http.Client();
  }

  Future<void> _clearSession() async {
    try {
      await _client.post(
        Uri.parse('$baseUrl/auth/logout/'),
      );
    } catch (e) {

    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      _initClient();
      await _clearSession();

      final response = await _client.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);
      print('Login response: ${response.statusCode} - $data');

      if (response.statusCode == 200 && data['status'] == 'success') {
        return {
          'success': true,
          'user': data['data']['user'],
          'sessionId': data['data']['session_id'],
          'csrfToken': data['data']['csrf_token'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/auth/me/'),
      );

      final data = jsonDecode(response.body);
      print('Get current user response: ${response.statusCode} - $data');

      if (response.statusCode == 200 && data['status'] == 'success') {
        return {
          'success': true,
          'user': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Not authenticated',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error : ${e.toString()}',
      };
    }
  }

  Future<void> logout() async {
    try {
      await _client.post(
        Uri.parse('$baseUrl/auth/logout/'),
      );
    } catch (e) {
      print('Logout error: $e');
    } finally {
      _client.close();
    }
  }

  void dispose() {
    _client.close();
  }
}