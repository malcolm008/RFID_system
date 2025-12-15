import 'package:flutter/material.dart';
import 'attendance_model.dart';

class AttendanceProvider extends ChangeNotifier {
  final List<AttendanceRecord> _allRecords = [
    AttendanceRecord(
      id: '1',
      personName: 'John Doe',
      role: 'Student',
      className: 'CS Year 1',
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      status: AttendanceStatus.present,
      device: 'Room A - Device 1',
    ),
    AttendanceRecord(
      id: '2',
      personName: 'Jane Smith',
      role: 'Student',
      className: 'CS Year 2',
      time: DateTime.now().subtract(const Duration(minutes: 15)),
      status: AttendanceStatus.late,
      device: 'Room B - Device 2',
    ),
  ];

  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  List<AttendanceRecord> get records {
    return _allRecords
        .where((r) =>
    r.time.year == _selectedDate.year &&
        r.time.month == _selectedDate.month &&
        r.time.day == _selectedDate.day)
        .toList();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
}
