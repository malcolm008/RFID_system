import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'course_model.dart';

class CourseProvider extends ChangeNotifier {
  final String baseUrl = "http://127.0.0.1:8000/api/courses/";

  final List<Course> _courses = [];
  bool _loading = false;

  List<Course> get courses => _courses;
  bool get isLoading => _loading;

  Future<void> loadCourses() async {
    _loading = true;
    notifyListeners();

    try{
      final res = await http.get(
        Uri.parse("${baseUrl}list/"),
      );

      if (res.statusCode == 200) {
        final jsonResponse = jsonDecode(res.body);

        if (jsonResponse["status"] == "success") {
          final List dataList = jsonResponse["data"];

          _courses
            ..clear()
            ..addAll(
              dataList.map((json) => Course.fromJson(json)).toList(),
            );
        } else {
          throw Exception(jsonResponse["message"]);
        }
      } else {
        throw Exception("Failed to load courses");
      }
    } catch (e) {
      debugPrint("Error loading courses: $e");
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> addCourse(Course course) async {
    try {
      final res = await http.post(
        Uri.parse("${baseUrl}create/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(course.toJson()),
      );

      final response = jsonDecode(res.body);

      if (res.statusCode == 201 && response["status"] == "success") {
        final newCourse = Course.fromJson(response["data"]);
        _courses.add(newCourse);
        notifyListeners();
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
        Uri.parse("${baseUrl}update/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(course.toJson()),
      );

      final response = jsonDecode(res.body);

      if (res.statusCode == 200 && response["status"] == "success") {
        final updatedCourse = Course.fromJson(response["data"]);

        final index = _courses.indexWhere((c) => c.id == updatedCourse.id);

        if (index != -1) {
          _courses[index] = updatedCourse;
          notifyListeners();
        }
      } else {
        throw Exception(response["message"]);
      }
    } catch (e) {
      debugPrint("Error updating course: $e");
      rethrow;
    }
  }
}