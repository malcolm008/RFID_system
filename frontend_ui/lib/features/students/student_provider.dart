import 'package:flutter/material.dart';
import 'student_model.dart';

class StudentProvider extends ChangeNotifier {
  final List<Student> _students = [
    Student(
      id: '1',
      name: 'John Doe',
      regNumber: 'STU-001',
      program: 'Bsc in Computer Engineering',
      year: 2,
      hasRfid: true,
      hasFingerprint: true,
    ),
    Student(
      id: '2',
      name: 'Jane Smith',
      regNumber: 'STU-002',
      program: 'Bsc in Business Information and technology',
      year: 3,
      hasRfid: false,
      hasFingerprint: false,
    ),
  ];

  List<Student> get students => _students;

  void addStudent(Student student) {
    _students.add(student);
    notifyListeners();
  }

  void updateStudent(Student updated) {
    final index = _students.indexWhere((s) => s.id == updated.id);
    _students[index] = updated;
    notifyListeners();
  }
}