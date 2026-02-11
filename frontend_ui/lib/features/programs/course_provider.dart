import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'course_model.dart';


class CourseProvider extends ChangeNotifier {
  final String baseUrl = "http://192.168.100.239/attendance_api/course";
  final List<Course> _courses = [];

  List<Course> get courses => _courses;

  Future<void> loadCourses() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/list.php"));
      if(res.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(res.body);

        if(jsonResponse["status"] == "success") {
          final List<dynamic> dataList = jsonResponse["data"];
          _courses.clear();
          _courses.addAll(dataList.map((json) => Course(
            id: json["id"].toString(),
            name: json["name"],
            code: json["code"],
            department: json["department"],
            year: int.parse(json["year"].toString()),
            semester: int.parse(json["semester"].toString()),
            teacherName: json["teacherName"],
          )));
          notifyListeners();
        } else {
          throw Exception(jsonResponse["message"]);
        }
      } else {
        throw Exception("Failed to load courses");
      }
    } catch (e) {
      debugPrint("Error loading courses: $e");
    }
  }

  Future<void> addCourse(Course course) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/create.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": course.name,
          "code": course.code,
          "department": course.department,
          "year": course.year,
          "semester": course.semester,
          "teacherName": course.teacherName,
        }),
      );

      final response = jsonDecode(res.body);
      if (res.statusCode == 200 && response["status"] == "success") {
        await loadCourses();
      } else {
        throw Exception(response["message"]);
      }
    } catch (e) {
      debugPrint("Error adding course: $e");
      rethrow;
    }
  }

  Future<void> updateCourse(Course course) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/update.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id": course.id,
          "name": course.name,
          "code": course.code,
          "department": course.department,
          "semester": course.semester,
          "year": course.year,
          "teacherName": course.teacherName,
        }),
      );

      final response = jsonDecode(res.body);
      if (res.statusCode == 200 && response["status"] == "success") {
        await loadCourses();
      } else {
        throw Exception(response["message"]);
      }
    } catch (e) {
      debugPrint("Error updating course: $e");
      rethrow;
    }
  }
}