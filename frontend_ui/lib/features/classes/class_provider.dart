import 'package:flutter/material.dart';
import 'class_model.dart';
import 'subject_model.dart';
import 'timetable_model.dart';

class ClassProvider extends ChangeNotifier {
  final List<SchoolClass> classes = [
    SchoolClass(id: '1', name: 'CS Year 1', level: 'Undergraduate'),
    SchoolClass(id: '2', name: 'CS Year 2', level: 'Undergraduate'),
  ];

  final List<Subject> subjects = [
    Subject(
      id: '1',
      name: 'Data Structures',
      code: 'CS201',
      teacherName: 'Mr. John',
    ),
    Subject(
      id: '2',
      name: 'Operating Systems',
      code: 'CS301',
      teacherName: 'Ms. Jane',
    ),
  ];

  final List<TimetableEntry> timetable = [
    TimetableEntry(
      id: '1',
      className: 'CS Year 1',
      subjectName: 'Data Structures',
      teacherName: 'Mr. John',
      day: 'Monday',
      startTime: '09:00',
      endTime: '11:00',
    ),
    TimetableEntry(
      id: '2',
      className: 'CS Year 2',
      subjectName: 'Operating Systems',
      teacherName: 'Ms. Jane',
      day: 'Tuesday',
      startTime: '10:00',
      endTime: '12:00',
    ),
  ];
}