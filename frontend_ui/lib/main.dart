import 'package:flutter/material.dart';
import 'package:frontend_ui/core/services/notification_provider.dart';
import 'package:frontend_ui/features/admin/admin_provider.dart';
import 'package:frontend_ui/features/dashboard/stats_provider.dart';
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
import 'core/services/notification_provider.dart';
import 'core/services/notification_service.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  final notificationProvider = NotificationProvider();
  await notificationProvider.init();

  runApp(AttendanceApp(notificationProvider: notificationProvider));
}

class AttendanceApp extends StatelessWidget {
  final NotificationProvider notificationProvider;

  const AttendanceApp({super.key, required this.notificationProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: notificationProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => StudentProvider(notificationProvider: context.read<NotificationProvider>(),)),
        ChangeNotifierProvider(create: (context) => TeacherProvider(notificationProvider: context.read<NotificationProvider>(),)),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (context) => ProgramProvider(notificationProvider: context.read<NotificationProvider>(),)),
        ChangeNotifierProvider(create: (context) => CourseProvider(notificationProvider: context.read<NotificationProvider>(),)),
        ChangeNotifierProvider(create: (context) => DeviceProvider(notificationProvider: context.read<NotificationProvider>(),)),
        ChangeNotifierProvider(create: (_) => TimetableProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
        ChangeNotifierProvider(create: (context) => AdminProvider(notificationProvider: context.read<NotificationProvider>(),),),
      ],
      child: Consumer2<SettingsProvider, AuthProvider>(
        builder: (context, settings, authProvider, child) {
          return FutureBuilder(
            future: authProvider.che,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: settings.themeMode,
                home: const LoginScreen(),
                routes: AppRoutes.routes,
              );
            },
          );
        },
      ),
    );
  }
}
