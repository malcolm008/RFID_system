import 'teacher_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TeacherApi {
  static const String baseUrl = "http://127.0.0.1:8000/attendance_api/teachers";

  static Future<List<Teacher>> fetchTeachers() async {
    final response = await http.get(Uri.parse("$baseUrl/list/"));

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      print("Decode Body: $body");
      print("Body type: ${body.runtimeType}");

      if (body is Map && body.containsKey('data')) {
        final data = body['data'];
        print("Data type: ${data.runtimeType}");
        print("Data value: $data");

        if (data is List) {
          return data
              .map((e) => Teacher.fromJson(e))
              .toList();
        } else {
          throw Exception("Data is not a list. It's: ${data.runtimeType}");
        }
      } else {
        throw Exception("Response doesn't contain 'data' key");
      }
    } else {
      throw Exception('Failed to load teachers. Status: ${response.statusCode}');
    }
  }

  static Future<void> addTeacher(Teacher teacher) async {
    final response = await http.post(
      Uri.parse("$baseUrl/create/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(teacher.toJson()),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode != 201) {
      throw Exception(body['message'] ?? 'Failed to add teacher');
    }
  }

  static Future<void> updateTeacher(Teacher teacher) async {
    final response = await http.post(
      Uri.parse("$baseUrl/update/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(teacher.toJson()),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Failed to update teacher');
    }
  }

  static Future<void> deleteTeacher(String id) async {
    final response = await http.post(
      Uri.parse("$baseUrl/delete/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id": int.parse(id)}),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['status'] == 'success') {
      print("Teacher deleted: $id");
    } else {
      throw Exception(body['message'] ?? 'Failed to delete teacher');
    }
  }

  static Future<void> bulkDeleteTeachers(List<String> ids) async {
    final response = await http.post(
      Uri.parse("$baseUrl/bulk-delete/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"ids": ids.map((e) => int.parse(e)).toList()}),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['status'] == 'success') {
      print("Teachers deleted: ${ids.join(', ')}");
    } else {
      throw Exception(body['message'] ?? "Failed to bulk delete teachers");
    }
  }
}