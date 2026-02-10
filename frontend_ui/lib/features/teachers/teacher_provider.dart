import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'teacher_model.dart';

class TeacherProvider extends ChangeNotifier {
  final String baseUrl = "http://127.0.0.1:8000/attendance_api/teachers";
  final List<Teacher> _teachers = [];

  List<Teacher> get teachers => _teachers;

  Future<void> loadTeachers() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/list/"));
      print("Load Teachers Response: ${res.statusCode} - ${res.body}");

      if (res.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(res.body);

        if (jsonResponse["status"] == "success") {
          final List<dynamic> dataList = jsonResponse["data"];
          _teachers.clear();
          _teachers.addAll(dataList.map((json) => Teacher.fromJson(json)).toList());
          notifyListeners();
        } else {
          throw Exception(jsonResponse["message"] ?? "Unknown error");
        }
      } else {
        throw Exception("Failed to load teachers: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Error loading teachers: $e");
      rethrow;
    }
  }

  Future<void> addTeacher(Teacher teacher) async {

  }

  Future<void> updateTeacher(Teacher teacher) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/update.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id": teacher.id,
          "name": teacher.name,
          "email": teacher.email,
          "course": teacher.course,
          "department": teacher.department,
          "hasRfid": teacher.hasRfid,
          "hasFingerprint": teacher.hasFingerprint,
        }),
      );
      final response = jsonDecode(res.body);
      if (res.statusCode == 200 && response["status"] == "success") {
        await loadTeachers();
      } else {
        throw Exception(response["message"]);
      }
    } catch (e) {
      debugPrint("Error updating teacher: $e");
      rethrow;
    }
  }
}
