import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'student_model.dart';

class StudentProvider extends ChangeNotifier {
  final String baseUrl = "http://127.0.0.1:8000/attendance_api/students";
  final List<Student> _students = [];

  List<Student> get students => _students;

  Future<void> loadStudents() async {
    try{
      final res = await http.get(Uri.parse("$baseUrl/list/"));
      print("Load Students Response: ${res.statusCode} - ${res.body}");

      if (res.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(res.body);

        if (jsonResponse["status"] == "success") {
          final List<dynamic> dataList = jsonResponse["data"];
          _students.clear();
          _students.addAll(dataList.map((json) => Student.fromJson(json)).toList());
          notifyListeners();
        } else {
          throw Exception(jsonResponse["message"] ?? "Unknown error");
        }
      } else {
        throw Exception("Failed to load students: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Error loading students: $e");
      rethrow;
    }
  }

  Future<void> addStudent(Student student) async {
    try {
      final Map<String, dynamic> studentData = {
        "name": student.name,
        "regNumber": student.regNumber,
        "program": student.program,
        "year": student.year,
        "hasRfid": student.hasRfid ? 1 :0,
        "hasFingerprint": student.hasFingerprint ? 1 : 0,
      };

      print("Sending student data: $studentData");

      final res = await http.post(
        Uri.parse("$baseUrl/create/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(studentData),
      );

      print("Add Student Response: ${res.statusCode} - ${res.body}");

      final Map<String, dynamic> response = jsonDecode(res.body);
      if (res.statusCode == 201 && response["status"] == "success") {
        await loadStudents();
      } else {
        throw Exception(response["message"] ?? "Failed to add student");
      }
    } catch(e) {
      debugPrint("Error adding student: $e");
      rethrow;
    }
  }

  Future<void> updateStudent(Student student) async {
    try {
      final Map<String, dynamic> studentData = {
        "id": int.parse(student.id),
        "name": student.name,
        "regNumber": student.regNumber,
        "program": student.program,
        "year": student.year,
        "hasRfid": student.hasRfid ? 1 : 0,
        "hasFingerprint": student.hasFingerprint ? 1 : 0,
      };

      print("Updating student data: $studentData");

      final res = await http.post(
        Uri.parse("$baseUrl/update/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(studentData),
      );

      print("Update Student Response: ${res.statusCode} - ${res.body}");

      final Map<String, dynamic> response = jsonDecode(res.body);
      if(res.statusCode == 200 && response["status"] == "success") {
        await loadStudents();
      } else {
        throw Exception(response["message"] ?? "Failed to update student");
      }
    } catch (e) {
      debugPrint("Error updating student: $e");
      rethrow;
    }
  }
}
