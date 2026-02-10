import 'student_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StudentApi {
  static const String baseUrl = "http://127.0.0.1:8000/attendance_api/students";

  static Future<List<Student>> fetchStudents() async {
    final response = await http.get(Uri.parse("$baseUrl/list/"));

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      print("Decoded Body: $body");
      print("Body type: ${body.runtimeType}");

      // Check if 'data' exists and is a list
      if (body is Map && body.containsKey('data')) {
        final data = body['data'];
        print("Data type: ${data.runtimeType}");
        print("Data value: $data");

        if (data is List) {
          return data
              .map((e) => Student.fromJson(e))
              .toList();
        } else {
          throw Exception("Data is not a list. It's: ${data.runtimeType}");
        }
      } else {
        throw Exception("Response doesn't contain 'data' key");
      }
    } else {
      throw Exception('Failed to load students. Status: ${response.statusCode}');
    }
  }
  static Future<void> addStudent(Student student) async {
    final response = await http.post(
      Uri.parse("$baseUrl/create/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(student.toJson()),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode != 201) {
      throw Exception(body['message'] ?? 'Failed to add student');
    }
  }

  static Future<void> updateStudent(Student student) async {
    final response = await http.post(
      Uri.parse("$baseUrl/update/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(student.toJson()),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Failed to update student');
    }
  }
}