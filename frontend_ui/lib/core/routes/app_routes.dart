import 'package:flutter/material.dart';
import 'package:frontend_ui/features/attendance/attendance_screen.dart';
import 'package:frontend_ui/features/reports/report_screen.dart';
import 'package:frontend_ui/features/students/student_list_screen.dart';
import 'package:frontend_ui/features/teachers/teacher_list_screen.dart';
import 'package:frontend_ui/features/devices/devices_screen.dart';
import 'package:frontend_ui/features/programs/program_screen.dart';
import 'package:frontend_ui/features/programs/subjects_screen.dart';
import 'package:frontend_ui/features/programs/timetable_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';

class AppRoutes {
  static const dashboard = '/dashboard';
  static const students = '/students';
  static const teachers = '/teachers';
  static const attendance = '/attendance';
  static const reports = '/reports';
  static const devices = '/devices';
  static const classes = '/programs';
  static const subjects = '/subjects';
  static const timetable = '/timetable';

  static Map<String, WidgetBuilder> routes = {
    dashboard: (context) => const DashboardScreen(),
    students: (context) => const StudentListScreen(),
    teachers: (context) =>  const TeacherListScreen(),
    attendance: (context) => const AttendanceScreen(),
    reports: (context) => const ReportsScreen(),
    devices: (context) => const DevicesScreen(),
    classes: (context) => const ProgramsScreen(),
    subjects: (context) => const SubjectsScreen(),
    timetable: (context) => const TimetableScreen(),
  };
}