import 'package:flutter/material.dart';
import 'class_model.dart';
import 'subject_model.dart';
import 'timetable_model.dart';

class ClassProvider extends ChangeNotifier {
  final List<SchoolClass> classes = [
    SchoolClass(id: '1', name: 'Bsc in Computer Engineering and Information Technology', level: 'Undergraduate', duration: '4 Years', department: 'Department of Computer Science'),
    SchoolClass(id: '2', name: 'Bsc in Business Information and Technology', level: 'Undergraduate', duration: '3 Years', department: 'Department in Business Administration'),
  ];

  final List<TimetableEntry> timetable = [
    TimetableEntry(
      id: '1',
      program: 'Bsc in Computer Engineering',
      course: 'Data Structures',
      teacherName: 'Mr. John',
      day: 'Monday',
      device: 'RFID 001',
      year: 2,
      location: 'BH 307',
      startTime: '09:00',
      endTime: '11:00',
    ),
    TimetableEntry(
      id: '2',
      program: 'Bsc in Computer Engineering',
      course: 'Operating Systems',
      teacherName: 'Ms. Jane',
      day: 'Tuesday',
      device: 'HYBRID 003',
      year: 1,
      location: 'BH 305',
      startTime: '10:00',
      endTime: '12:00',
    ),
  ];
}