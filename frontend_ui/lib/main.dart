import 'package:flutter/material.dart';
import 'package:frontend_ui/core/services/notification_provider.dart';
import 'package:frontend_ui/features/programs/course_provider.dart';
import 'package:frontend_ui/features/programs/program_provider.dart';
import 'package:frontend_ui/features/programs/program_screen.dart';
import 'package:frontend_ui/features/programs/course_screen.dart';
import 'package:frontend_ui/features/programs/timetable_screen.dart';
import 'package:frontend_ui/features/devices/device_provider.dart';
import 'package:frontend_ui/features/devices/devices_screen.dart';
import 'package:frontend_ui/features/settings/settings_provider.dart';
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
import 'features/settings/settings_provider.dart';
import 'features/settings/settings_screen.dart';
import 'package:frontend_ui/features/programs/timetable_provider.dart';
import 'core/services/notification_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationProvider = NotificationProvider();
  notificationProvider.init();

  runApp(AttendanceApp(notificationProvider: notificationProvider));
}

class AttendanceApp extends StatelessWidget {
  final NotificationProvider notificationProvider;

  const AttendanceApp({super.key, required this.notificationProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => TeacherProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => ProgramProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
        ChangeNotifierProvider(create: (_) => TimetableProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => notificationProvider),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            home: const LoginScreen(),
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}
