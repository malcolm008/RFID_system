import 'package:flutter/material.dart';
import 'student_model.dart';
import 'student_api.dart';

class StudentProvider extends ChangeNotifier {
  List<Student> _students = [];
  bool isLoading = false;

  List<Student> get students => _students;

  Future<void> loadStudents() async {
    isLoading = true;
    notifyListeners();

    _students = await StudentApi.fetchStudents();

    isLoading = false;
    notifyListeners();
  }

  Future<void> addStudent(Student student) async {
    await StudentApi.addStudent(student);
    await loadStudents();
  }

  Future<void> updateStudent(Student student) async {
    await StudentApi.updateStudent(student);
    await loadStudents();
  }
}
