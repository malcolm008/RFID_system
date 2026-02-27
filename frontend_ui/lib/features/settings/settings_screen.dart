import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/app_scaffold.dart';
import 'settings_provider.dart';
import 'admin_edit_dialog.dart';
import '../../main.dart';
import '../../core/services/notification_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
                      'Settings',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.grey.shade800,
                      ),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Profile Section
            _buildProfileHeader(context),

            const SizedBox(height: 24),

            // Notifications Category
            _buildSettingsCategory(
              context: context,
              icon: Icons.notifications_active_outlined,
              title: "Notifications",
              color: Colors.blue,
              child: Column(
                children: [
                  Consumer<NotificationProvider>(
                    builder: (context, notificationProvider, child) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: notificationProvider.permissionGranted
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              notificationProvider.permissionGranted
                                  ? Icons.notifications_active
                                  : Icons.notifications_off,
                              color: notificationProvider.permissionGranted
                                ? Colors.green
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notificationProvider.permissionGranted
                                        ? 'Notifications Enabled'
                                        : 'Notifications Disabled',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notificationProvider.permissionGranted
                                        ? 'You will receive schedule reminders'
                                        : 'Enable to get reminders about upcoming schedules',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!notificationProvider.permissionGranted)
                              ElevatedButton(
                                onPressed: () async {
                                  await notificationProvider.requestPermission();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                child: const Text('Enable'),
                              ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 8),
                  _buildModernSwitchTile(
                    context: context,
                    value: settings.notificationsEnabled,
                    onChanged: settings.toggleNotifications,
                    title: "Enable Notifications",
                    subtitle: "Get reminders about upcoming classes",
                    icon: Icons.notifications_outlined,
                  ),
                  if (settings.notificationsEnabled) ...[
                    const SizedBox(height: 8),
                    _buildDropdownTile(
                      context: context,
                      title: "Reminder Time",
                      subtitle: "How early to notify you",
                      value: settings.reminderMinutes,
                      items: const [
                        DropdownMenuItem(value: 5, child: Text("5 minutes before")),
                        DropdownMenuItem(value: 10, child: Text("10 minutes before")),
                        DropdownMenuItem(value: 30, child: Text("30 minutes before")),
                        DropdownMenuItem(value: 60, child: Text("1 hour before")),
                      ],
                      onChanged: (value) {
                        if (value != null) settings.setReminderMinutes(value);
                      },
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Appearance Category
            _buildSettingsCategory(
              context: context,
              icon: Icons.palette_outlined,
              title: "Appearance",
              color: Colors.purple,
              child: Column(
                children: [
                  _buildThemeOption(
                    context,
                    value: ThemeMode.light,
                    groupValue: settings.themeMode,
                    onChanged: settings.setThemeMode,
                    title: "Light Mode",
                    icon: Icons.wb_sunny_outlined,
                    description: "Bright and clean interface",
                  ),
                  _buildThemeOption(
                    context,
                    value: ThemeMode.dark,
                    groupValue: settings.themeMode,
                    onChanged: settings.setThemeMode,
                    title: "Dark Mode",
                    icon: Icons.nightlight_outlined,
                    description: "Easy on the eyes at night",
                  ),
                  _buildThemeOption(
                    context,
                    value: ThemeMode.system,
                    groupValue: settings.themeMode,
                    onChanged: settings.setThemeMode,
                    title: "System Default",
                    icon: Icons.settings_outlined,
                    description: "Follow your device settings",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Timetable Preferences Category
            _buildSettingsCategory(
              context: context,
              icon: Icons.calendar_today_outlined,
              title: "Timetable Preferences",
              color: Colors.green,
              child: Column(
                children: [
                  _buildSliderTile(
                    context: context,
                    title: "Start Hour",
                    subtitle: "When your day begins",
                    value: settings.startHour.toDouble(),
                    min: 6,
                    max: 12,
                    divisions: 6,
                    onChanged: (value) => settings.setStartHour(value.round()),
                    formatValue: (value) => "${value.round()}:00",
                  ),
                  const Divider(height: 24),
                  _buildSliderTile(
                    context: context,
                    title: "End Hour",
                    subtitle: "When your day ends",
                    value: settings.endHour.toDouble(),
                    min: 12,
                    max: 22,
                    divisions: 10,
                    onChanged: (value) => settings.setEndHour(value.round()),
                    formatValue: (value) => "${value.round()}:00",
                  ),
                  const Divider(height: 24),
                  _buildModernSwitchTile(
                    context: context,
                    value: settings.showWeekends,
                    onChanged: settings.toggleWeekends,
                    title: "Show Weekends",
                    subtitle: "Display Saturday and Sunday in timetable",
                    icon: Icons.weekend_outlined,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // System Category
            _buildSettingsCategory(
              context: context,
              icon: Icons.system_update_outlined,
              title: "System",
              color: Colors.orange,
              child: Column(
                children: [
                  _buildActionTile(
                    context: context,
                    icon: Icons.delete_outline,
                    title: "Clear Cache",
                    subtitle: "Free up storage space",
                    onTap: () => _showClearCacheDialog(context),
                  ),
                  _buildActionTile(
                    context: context,
                    icon: Icons.info_outline,
                    title: "About App",
                    subtitle: "Academic Management System v1.0",
                    onTap: () => _showAboutDialog(context),
                    showArrow: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Version info at bottom
            Center(
              child: Text(
                "Version 1.0.0",
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final adminData = {
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'phone': '+1 234 567 890',
      'department': 'Administration',
      'position': 'System Administrator',
      'role': 'Administrator',
      'bio': 'Experienced administrator with 10+ years in system management. Passionate about educational technology and system optimization.',
      'isActive': true,
      'imageUrl': null,
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.grey.shade800, Colors.grey.shade900]
              : [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showEditAdminDialog(context, adminData),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => _showEditAdminDialog(context, adminData),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "John Doe",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Administrator",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: Colors.blue.shade400,
                size: 22,
              ),
              onPressed: () => _showEditAdminDialog(context, adminData),
              tooltip: 'Edit Profile',
              splashRadius: 24,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildSettingsCategory({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildModernSwitchTile({
    required BuildContext context,
    required bool value,
    required Function(bool) onChanged,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (value ? Colors.blue : Colors.grey).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: value ? Colors.blue : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required int value,
    required List<DropdownMenuItem<int>> items,
    required void Function(int?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.timer_outlined, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButton<int>(
              value: value,
              items: items,
              onChanged: onChanged,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down),
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
      BuildContext context, {
        required ThemeMode value,
        required ThemeMode groupValue,
        required Function(ThemeMode) onChanged,
        required String title,
        required IconData icon,
        required String description,
      }) {
    final isSelected = value == groupValue;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.blue
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.blue : Colors.grey,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.blue : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required void Function(double) onChanged,
    required String Function(double) formatValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.access_time, color: Colors.green, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                formatValue(value),
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
          activeColor: Colors.green,
          inactiveColor: Colors.grey.shade300,
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showArrow = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.orange, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: showArrow
          ? Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400)
          : null,
      onTap: onTap,
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Clear Cache"),
          content: const Text(
            "This will clear all temporary data. Your settings will not be affected. Continue?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Cache cleared successfully"),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text("Clear"),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: "Academic Management System",
      applicationVersion: "Version 1.0.0",
      applicationIcon: const FlutterLogo(size: 50),
      applicationLegalese: "© 2024 Your Institution",
      children: [
        const SizedBox(height: 16),
        const Text(
          "A comprehensive solution for managing academic schedules, "
              "attendance, and institutional resources.",
        ),
      ],
    );
  }

  void _showEditAdminDialog(BuildContext context, Map<String, dynamic> adminData) {
    showDialog(
      context: context,
      builder: (context) => AdminEditDialog(adminData: adminData),
    ).then((updatedData) {
      if (updatedData != null) {
        // Update your provider or state with the new data
        print('Updated admin data: $updatedData');

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Here you would typically update your provider
        // context.read<SettingsProvider>().updateAdminProfile(updatedData);
      }
    });
  }
}