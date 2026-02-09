import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'student_model.dart';

class StudentProvider extends ChangeNotifier {
  final String baseUrl = "http://192.168.100.239/attendance_api/students";
  final List<Student> _students = [];

  List<Student> get students => _students;

  // Fetch all students from backend
  Future<void> loadStudents() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/list.php"));
      if (res.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(res.body);

        if (jsonResponse["status"] == "success") {
          final List<dynamic> dataList = jsonResponse["data"];
          _students.clear();
          _students.addAll(dataList.map((json) => Student(
            id: json["id"].toString(),
            name: json["name"],
            regNumber: json["regNumber"],  // match your JSON
            program: json["program"],
            year: int.parse(json["year"].toString()),
            hasRfid: json["hasRfid"] == 1,
            hasFingerprint: json["hasFingerprint"] == 1,
          )));
          notifyListeners();
        } else {
          throw Exception(jsonResponse["message"]);
        }
      } else {
        throw Exception("Failed to load students");
      }
    } catch (e) {
      debugPrint("Error loading students: $e");
    }
  }


  // Add new student
  Future<void> addStudent(Student student) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/create.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": student.name,
          "regNumber": student.regNumber,
          "program": student.program,
          "year": student.year,
          "hasRfid": student.hasRfid,
          "hasFingerprint": student.hasFingerprint,
        }),
      );

      final response = jsonDecode(res.body);
      if (res.statusCode == 200 && response["status"] == "success") {
        // Re-fetch full list from server
        await loadStudents();
      } else {
        throw Exception(response["message"]);
      }
    } catch (e) {
      debugPrint("Error adding student: $e");
      rethrow;
    }
  }

  // Update student
  Future<void> updateStudent(Student student) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/update.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id": student.id,
          "name": student.name,
          "regNumber": student.regNumber,
          "program": student.program,
          "year": student.year,
          "hasRfid": student.hasRfid,
          "hasFingerprint": student.hasFingerprint,
        }),
      );

      final response = jsonDecode(res.body);
      if (res.statusCode == 200 && response["status"] == "success") {
        // Re-fetch full list from server
        await loadStudents();
      } else {
        throw Exception(response["message"]);
      }
    } catch (e) {
      debugPrint("Error updating student: $e");
      rethrow;
    }
  }
}
