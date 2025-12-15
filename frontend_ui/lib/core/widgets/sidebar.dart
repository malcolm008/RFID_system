import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/auth/auth_model.dart';
import '../routes/app_routes.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final theme = Theme.of(context);

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // App Title
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.fingerprint,
                    color: theme.colorScheme.onPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Attendance System',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Menu Items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  _MenuItem(
                    title: 'Dashboard',
                    icon: Icons.dashboard_outlined,
                    route: AppRoutes.dashboard,
                  ),

                  const SizedBox(height: 8),

                  if (user?.role == UserRole.admin)
                    _MenuItem(
                      title: 'Students',
                      icon: Icons.people_outline,
                      route: AppRoutes.students,
                    ),

                  if (user?.role == UserRole.admin) const SizedBox(height: 8),

                  if (user?.role == UserRole.admin)
                    _MenuItem(
                      title: 'Teachers',
                      icon: Icons.school_outlined,
                      route: AppRoutes.teachers,
                    ),

                  const SizedBox(height: 8),

                  _MenuItem(
                    title: 'Attendance',
                    icon: Icons.fact_check_outlined,
                    route: AppRoutes.attendance,
                  ),

                  const SizedBox(height: 8),

                  _MenuItem(
                    title: 'Reports',
                    icon: Icons.bar_chart_outlined,
                    route: AppRoutes.reports,
                  ),

                  const SizedBox(height: 8),

                  if (user?.role == UserRole.admin)
                    _MenuItem(
                      title: 'Devices',
                      icon: Icons.devices_other_outlined,
                      route: AppRoutes.devices,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String route;

  const _MenuItem({
    required this.title,
    required this.icon,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = ModalRoute.of(context)?.settings.name == route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: isActive
            ? theme.colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => Navigator.pushReplacementNamed(context, route),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
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