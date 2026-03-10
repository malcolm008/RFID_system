import 'package:flutter/material.dart';
import 'package:frontend_ui/features/attendance/attendance_screen.dart';
import 'package:frontend_ui/features/programs/program_screen.dart';
import 'package:frontend_ui/features/programs/course_screen.dart';
import 'package:frontend_ui/features/programs/timetable_form_screen.dart';
import 'package:frontend_ui/features/programs/timetable_screen.dart';
import 'package:frontend_ui/features/devices/devices_screen.dart';
import 'package:frontend_ui/features/reports/report_screen.dart';
import 'package:frontend_ui/features/settings/settings_screen.dart';
import 'package:frontend_ui/features/students/student_form_screen.dart';
import 'package:frontend_ui/features/students/student_list_screen.dart';
import 'package:frontend_ui/features/teachers/teacher_list_screen.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/notification_provider.dart';
import 'package:provider/provider.dart';
import '../../core/services/notification_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AppScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Welcome back! Here\'s your overview',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isDarkMode
                        ? null
                        : [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Today, ${_getFormattedDate()}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.2,
              children: [
                _StatCard(
                  title: 'Students',
                  value: '1,200',
                  icon: Icons.school,
                  color:  theme.colorScheme.secondary,
                  gradientColors: [theme.colorScheme.primary, theme.colorScheme.secondary.withOpacity(0.5)],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentListScreen(),
                      ),
                    );
                  },
                ),

                _StatCard(
                  title: 'Teachers',
                  value: '75',
                  icon: Icons.people,
                  color:  theme.colorScheme.secondary,
                  gradientColors: [theme.colorScheme.primary, theme.colorScheme.secondary.withOpacity(0.5)],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TeacherListScreen(),
                      ),
                    );
                  },
                ),

                _StatCard(
                  title: 'Programs',
                  value: '75',
                  icon: Icons.people,
                  color:  theme.colorScheme.secondary,
                  gradientColors: [theme.colorScheme.primary, theme.colorScheme.secondary.withOpacity(0.5)],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProgramsScreen(),
                      ),
                    );
                  },
                ),


                _StatCard(
                  title: 'Courses',
                  value: '92',
                  icon: Icons.book,
                  color:  theme.colorScheme.secondary,
                  gradientColors: [theme.colorScheme.primary, theme.colorScheme.secondary.withOpacity(0.5)],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CoursesScreen(),
                      ),
                    );
                  },
                ),

                _StatCard(
                  title: 'Active Devices',
                  value: '14',
                  icon: Icons.devices,
                  color:  theme.colorScheme.secondary,
                  gradientColors: [theme.colorScheme.primary, theme.colorScheme.secondary.withOpacity(0.5)],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DevicesScreen(),
                      ),
                    );
                  },
                ),

                _StatCard(
                  title: 'Today Attendance',
                  value: '92%',
                  icon: Icons.calendar_today,
                  color:  theme.colorScheme.secondary,
                  gradientColors: [theme.colorScheme.primary, theme.colorScheme.secondary.withOpacity(0.5)],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AttendanceScreen(),
                      ),
                    );
                  },
                ),
              ],

            ),

            const SizedBox(height: 40),

            // Charts Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildChartCard(
                    context,
                    title: 'Attendance Overview',
                    subtitle: 'Last 7 days',
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildQuickActions(context),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Recent Activity
            _buildRecentActivity(context),
          ],
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  Widget _buildChartCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required Color color,
      }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDarkMode
            ? null
            : [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'This week',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Placeholder for chart
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Attendance Chart',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDarkMode
            ? null
            : [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _buildActionItem(
            context,
            icon: Icons.add_circle,
            label: 'Add Program',
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProgramsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildActionItem(
              context,
              icon: Icons.add_circle_outline,
              label: 'Add Course',
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CoursesScreen(),
                  ),
                );
              }
          ),
          const SizedBox(height: 16),
          _buildActionItem(
              context,
              icon: Icons.calendar_month,
              label: 'Modify Timetable',
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TimetableScreen(),
                  ),
                );
              }
          ),
          const SizedBox(height: 16),
          _buildActionItem(
              context,
              icon: Icons.settings,
              label: 'Settings',
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(),
                  ),
                );
              }
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildRecentActivity(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final notificationProvider = context.watch<NotificationProvider>();
    final notifications = notificationProvider.notifications;

    final recentNotifications = [...notifications]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final latest = recentNotifications.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDarkMode
            ? null
            : [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          if (latest.isEmpty)
            Text(
              "No recent activity",
              style: theme.textTheme.bodyMedium,
            ),

          ...latest.map((notification) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildActivityItem(
                context,
                title: notification.title,
                subtitle: notification.body,
                time: _formatTime(notification.timestamp),
                icon: _getNotificationIcon(notification.type),
                color: _getNotificationColor(notification.type)
              ),
            );
          })
        ],
      ),
    );
  }

  Widget _buildActivityItem(
      BuildContext context, {
        required String title,
        required String subtitle,
        required String time,
        required IconData icon,
        required Color color,
      }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDarkMode ? theme.appBarTheme.surfaceTintColor : Colors.white,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final difference = DateTime.now().difference(time);

    if (difference.inMinutes < 1) return "just now";
    if (difference.inMinutes < 60) return "${difference.inMinutes} min ago";
    if (difference.inMinutes < 24) return "${difference.inMinutes} hr ago";

    return "${difference.inDays} day ago";
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.Reminder:
        return Icons.schedule;
      case NotificationType.system:
        return Icons.notifications;
      case NotificationType.enrollment:
        return Icons.add_circle;
      default:
        return Icons.info;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.Reminder:
        return Colors.orange.withOpacity(0.8);
      case NotificationType.system:
        return Colors.teal.withOpacity(0.8);
      case NotificationType.enrollment:
        return Colors.pinkAccent.withOpacity(0.8);
      default:
        return Colors.grey;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
