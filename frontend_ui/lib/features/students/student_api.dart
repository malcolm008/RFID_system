import 'dart:convert';
import 'package:http/http.dart' as http;
import 'student_model.dart';

class StudentApi {
  static const String baseUrl =
      "http://192.168.11.186/attendance_api/students"; // CHANGE IP

  static Future<List<Student>> fetchStudents() async {
    final response =
    await http.get(Uri.parse("$baseUrl/list.php"));

    final body = jsonDecode(response.body);

    return (body['data'] as List)
        .map((e) => Student.fromJson(e))
        .toList();
  }

  static Future<void> addStudent(Student student) async {
    await http.post(
      Uri.parse("$baseUrl/create.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(student.toJson()),
    );
  }

  static Future<void> updateStudent(Student student) async {
    await http.post(
      Uri.parse("$baseUrl/update.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(student.toJson()),
    );
  }
}
