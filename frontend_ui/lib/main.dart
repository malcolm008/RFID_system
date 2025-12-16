import 'package:flutter/material.dart';
import 'package:frontend_ui/features/classes/class_provider.dart';
import 'package:frontend_ui/features/classes/classes_screen.dart';
import 'package:frontend_ui/features/classes/subjects_screen.dart';
import 'package:frontend_ui/features/classes/timetable_screen.dart';
import 'package:frontend_ui/features/devices/device_provider.dart';
import 'package:frontend_ui/features/devices/devices_screen.dart';
import 'package:frontend_ui/features/students/student_list_screen.dart';
import 'package:frontend_ui/features/reports/report_provider.dart';
import 'package:frontend_ui/features/students/student_provider.dart';
import 'package:frontend_ui/features/teachers/teacher_list_screen.dart';
import 'package:frontend_ui/features/teachers/teacher_provider.dart';
import 'package:frontend_ui/features/attendance/attendance_provider.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';

void main() {
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => TeacherProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => ClassProvider()),
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
        routes: AppRoutes.routes,
      ),
    );
  }
}
