import 'package:flutter/material.dart';
import 'attendance_model.dart';

class AttendanceProvider extends ChangeNotifier {
  final List<AttendanceRecord> _allRecords = [
    AttendanceRecord(
      id: '1',
      personName: 'John Doe',
      role: 'Student',
      program: 'BSc in Computer Engineering and Information Technology',
      course: 'Procedural programming in C',
      year: 1,
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      status: AttendanceStatus.present,
      device: 'Room A - Device 1',
    ),
    AttendanceRecord(
      id: '2',
      personName: 'Jane Smith',
      role: 'Student',
      program: 'BSc in Computer Engineering and Information Technology',
      course: 'Introduction to Linux for Engineers',
      year: 1,
      time: DateTime.now().subtract(const Duration(minutes: 15)),
      status: AttendanceStatus.late,
      device: 'Room B - Device 2',
    ),
    AttendanceRecord(
      id: '3',
      personName: 'Dr. Robert Johnson',
      role: 'Teacher',
      program: 'BSc in Computer Engineering and Information Technology',
      course: 'Procedural programming in C',
      year: 1,
      time: DateTime.now().subtract(const Duration(minutes: 10)),
      status: AttendanceStatus.present,
      device: 'Room A - Device 3',
    ),
    AttendanceRecord(
      id: '4',
      personName: 'Mike Wilson',
      role: 'Student',
      program: 'BSc in Computer Engineering and Information Technology',
      course: 'Procedural programming in C',
      year: 1,
      time: DateTime.now().subtract(const Duration(minutes: 20)),
      status: AttendanceStatus.late,
      device: 'Room A - Device 4',
    ),
    AttendanceRecord(
      id: '5',
      personName: 'Prof. Sarah Williams',
      role: 'Teacher',
      program: 'BSc in Computer Engineering and Information Technology',
      course: 'Data Structures and Algorithms',
      year: 2,
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      status: AttendanceStatus.present,
      device: 'Room C - Device 1',
    ),
    AttendanceRecord(
      id: '6',
      personName: 'Emily Brown',
      role: 'Student',
      program: 'BSc in Computer Engineering and Information Technology',
      course: 'Data Structures and Algorithms',
      year: 2,
      time: DateTime.now().subtract(const Duration(minutes: 8)),
      status: AttendanceStatus.present,
      device: 'Room C - Device 2',
    ),
    AttendanceRecord(
      id: '7',
      personName: 'David Miller',
      role: 'Student',
      program: 'BSc in Electrical Engineering',
      course: 'Circuit Analysis',
      year: 1,
      time: DateTime.now().subtract(const Duration(minutes: 25)),
      status: AttendanceStatus.late,
      device: 'Room D - Device 1',
    ),
    AttendanceRecord(
      id: '8',
      personName: 'Dr. Lisa Anderson',
      role: 'Teacher',
      program: 'BSc in Electrical Engineering',
      course: 'Circuit Analysis',
      year: 1,
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      status: AttendanceStatus.present,
      device: 'Room D - Device 2',
    ),
  ];

  String _selectedCourse = '';
  RoleFilter _selectedRoleFilter = RoleFilter.both;
  String _searchQuery = '';

  // Get unique courses
  List<String> get courses {
    final uniqueCourses = _allRecords.map((r) => r.course).toSet().toList();
    uniqueCourses.sort();
    return uniqueCourses;
  }

  // Get filtered courses based on search
  List<String> get filteredCourses {
    if (_searchQuery.isEmpty) {
      return courses;
    }
    return courses
        .where((course) => course.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  String get selectedCourse => _selectedCourse;
  RoleFilter get selectedRoleFilter => _selectedRoleFilter;
  String get searchQuery => _searchQuery;

  // Get filtered records
  List<AttendanceRecord> get studentRecords {
    if (_selectedCourse.isEmpty) return [];

    return _allRecords
        .where((r) => r.course == _selectedCourse && r.role == 'Student')
        .toList();
  }

  List<AttendanceRecord> get teacherRecords {
    if (_selectedCourse.isEmpty) return [];

    return _allRecords
        .where((r) => r.course == _selectedCourse && r.role == 'Teacher')
        .toList();
  }

  void selectCourse(String course) {
    _selectedCourse = course;
    notifyListeners();
  }

  void setRoleFilter(RoleFilter filter) {
    _selectedRoleFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCourse = '';
    _selectedRoleFilter = RoleFilter.both;
    _searchQuery = '';
    notifyListeners();
  }
}

enum RoleFilter { students, teachers, both }