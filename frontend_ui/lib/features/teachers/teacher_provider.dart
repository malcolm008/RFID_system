import 'package:flutter/material.dart';
import 'teacher_model.dart';

class TeacherProvider extends ChangeNotifier {
  final List<Teacher> _teachers = [
    Teacher(
      id: '1',
      name: 'Mr. Alex Brown',
      email: 'alex@school.com',
      course: 'Mathematics',
      department: 'Department of Computer Science',
      hasRfid: true,
      hasFingerprint: true,
    ),
    Teacher(
      id: '2',
      name: 'Ms. Sarah White',
      email: 'sarah@school.com',
      course: 'Physics',
      department: 'Department of Business',
      hasRfid: false,
      hasFingerprint: false,
    ),
  ];

  List<Teacher> get teachers => _teachers;

  void addTeacher(Teacher teacher) {
    _teachers.add(teacher);
    notifyListeners();
  }

  void updateTeacher(Teacher updated) {
    final index = _teachers.indexWhere((t) => t.id == updated.id);
    _teachers[index] = updated;
    notifyListeners();
  }
}
