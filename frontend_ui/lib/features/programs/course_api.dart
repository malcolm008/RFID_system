import 'dart:convert';
import 'package:http/http.dart' as http;
import 'course_model.dart';
import 'package:provider/provider.dart';

class CourseApi {
  static const String baseUrl = "http://127.0.0.1:8000/attendance_api/courses/";

  static Future<List<Course>> fetchCourses() async {
    final response = await http.get(
        Uri.parse("${baseUrl}list/")
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List list = data['data'];
      return list.map((e) => Course.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load courses");
    }
  }

  static Future<Course> addCourse(Course course) async {
    final response = await http.post(
      Uri.parse("${baseUrl}create/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(course.toJson()),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 201) {
      return Course.fromJson(data['data']);
    } else {
      throw Exception(data['message']);
    }
  }

  static Future<Course> updateCourse(Course course) async {
    final response = await http.post(
      Uri.parse("${baseUrl}update/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(course.toJson()),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return Course.fromJson(data['data']);
    } else {
      throw Exception(data['message']);
    }
  }
}
