import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'teacher_model.dart';
import 'teacher_api.dart';

class TeacherProvider extends ChangeNotifier {
  final String baseUrl = "http://127.0.0.1:8000/attendance_api/teachers";
  final List<Teacher> _teachers = [];
  bool _isLoading = false;

  List<Teacher> get teachers => _teachers;
  bool get isLoading => _isLoading;

  Future<void> loadTeachers() async {
    _isLoading = true;
    notifyListeners();

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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTeacher(Teacher teacher) async {
    try {
      final Map<String, dynamic> teacherData = {
        "name": teacher.name,
        "email": teacher.email,
        "course": teacher.course,
        "department": teacher.department,
        "hasRfid": teacher.hasRfid ? 1 : 0,
        "hasFingerprint": teacher.hasFingerprint ? 1 : 0,
      };

      print("Sending teacher data: $teacherData");

      final res = await http.post(
        Uri.parse("$baseUrl/create/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(teacherData),
      );

      print("Add Teacher Response: ${res.statusCode} - ${res.body}");

      final Map<String, dynamic> response = jsonDecode(res.body);
      if (res.statusCode == 201 && response["status"] == "success") {
        await loadTeachers();
      } else {
        throw Exception(response["message"] ?? "Failed to add teacher");
      }
    } catch(e) {
      debugPrint("Error adding teacher: $e");
      rethrow;
    }
  }

  Future<void> updateTeacher(Teacher teacher) async {
    try {
      final Map<String, dynamic> teacherData = {
        "id": int.parse(teacher.id),
        "name": teacher.name,
        "email": teacher.email,
        "course": teacher.course,
        "department": teacher.department,
        "hasRfid": teacher.hasRfid ? 1 : 0,
        "hasFingerprint": teacher.hasFingerprint ? 1 : 0,
      };

      print("Updating teacher data: $teacherData");

      final res = await http.post(
        Uri.parse("$baseUrl/update/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(teacherData),
      );

      print("Update Teacher Response: ${res.statusCode} - ${res.body}");

      final Map<String, dynamic> response = jsonDecode(res.body);
      if(res.statusCode == 200 && response["status"] == "success") {
        await loadTeachers();
      } else {
        throw Exception(response["message"] ?? "Failed to update teacher");
      }
    } catch (e) {
      debugPrint("Error updating student: $e");
      rethrow;
    }
  }

  Future<void> deleteTeacher(String id) async {
    try {
      await TeacherApi.deleteTeacher(id);
      _teachers.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting teacher $id: $e');
      rethrow;
    }
  }

  Future<void> bulkDeleteTeachers(List<String> ids) async {
    try {
      await TeacherApi.bulkDeleteTeachers(ids);
      _teachers.removeWhere((t) => ids.contains(t.id));
      notifyListeners();
    } catch (e) {
      debugPrint('Error bulk deleting teachers: $e');
      rethrow;
    }
  }
}
