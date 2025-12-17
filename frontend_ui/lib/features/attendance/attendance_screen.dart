import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/app_scaffold.dart';
import 'attendance_provider.dart';
import 'attendance_model.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AttendanceProvider(),
      child: _AttendanceContent(),
    );
  }
}

class _AttendanceContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AppScaffold(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Course Attendance',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'View attendance by course and role',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Search and Filter Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.grey.shade900
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter Attendance',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Course Search
                      Container(
                        width: 600,
                        child: TextField(
                          onChanged: provider.setSearchQuery,
                          decoration: InputDecoration(
                            hintText: 'Search courses...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: isDarkMode
                                ? Colors.grey.shade800
                                : Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Course Selection
                      if (provider.searchQuery.isNotEmpty || provider.selectedCourse.isEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available Courses:',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.white : Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.grey.shade800.withOpacity(0.5)
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: provider.filteredCourses.map((course) {
                                  final isSelected = provider.selectedCourse == course;
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : isDarkMode
                                            ? Colors.grey.shade700
                                            : Colors.grey.shade300,
                                      ),
                                      color: isSelected
                                          ? theme.colorScheme.primary.withOpacity(0.1)
                                          : Colors.transparent,
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        onTap: () => provider.selectCourse(course),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 14,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.book,
                                                size: 18,
                                                color: isSelected
                                                    ? theme.colorScheme.primary
                                                    : Colors.grey.shade600,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                course,
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  fontWeight: isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                  color: isSelected
                                                      ? theme.colorScheme.primary
                                                      : isDarkMode
                                                      ? Colors.white
                                                      : Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),

                      if (provider.selectedCourse.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Divider(
                          color: isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade300,
                          height: 1,
                        ),
                        const SizedBox(height: 24),

                        // Selected Course and Role Filter
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.grey.shade800.withOpacity(0.3)
                                : theme.colorScheme.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selected Filters',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode ? Colors.white : Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 16),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Selected Course Card
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? Colors.grey.shade800
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isDarkMode
                                              ? Colors.grey.shade700
                                              : Colors.grey.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.book,
                                              color: theme.colorScheme.primary,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Course',
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  provider.selectedCourse,
                                                  style: theme.textTheme.bodyLarge?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: isDarkMode
                                                        ? Colors.white
                                                        : Colors.grey.shade800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.close,
                                              color: Colors.grey.shade500,
                                            ),
                                            onPressed: provider.clearFilters,
                                            tooltip: 'Clear filters',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 20),

                                  // Role Filter
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Filter by Role: ',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey.shade300),
                                          ),
                                          child: DropdownButton<RoleFilter>(
                                            value: provider.selectedRoleFilter,
                                            onChanged: (value) {
                                              if (value != null) {
                                                provider.setRoleFilter(value);
                                              }
                                            },
                                            isExpanded: true,
                                            underline: const SizedBox(),
                                            items: [
                                              DropdownMenuItem(
                                                value: RoleFilter.both,
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.groups, size: 16, color: Colors.blue),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Both',
                                                      style: TextStyle(
                                                        fontSize: 14
                                                      )
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value: RoleFilter.students,
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.school, size: 16, color: Colors.green),
                                                    const SizedBox(width: 8),
                                                    Text('Students Only', style: TextStyle(
                                                      fontSize: 14
                                                    )),
                                                  ],
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value: RoleFilter.teachers,
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.person,
                                                      size: 16,
                                                      color: Colors.orange
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text('Teachers Only', style: TextStyle(fontSize: 14)),
                                                  ],
                                                )
                                              )
                                            ]
                                          )
                                        )
                                      ],
                                    )
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Attendance Data Section
                _buildAttendanceDataSection(context, provider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceDataSection(
      BuildContext context,
      AttendanceProvider provider,
      ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (provider.selectedCourse.isEmpty) {
      return Container(
        height: 400,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Select a course to view attendance',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Search and select a course from the list above to see attendance records',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final showStudents = provider.selectedRoleFilter == RoleFilter.students ||
        provider.selectedRoleFilter == RoleFilter.both;
    final showTeachers = provider.selectedRoleFilter == RoleFilter.teachers ||
        provider.selectedRoleFilter == RoleFilter.both;

    // Check if there are no records
    final hasNoRecords = (!showStudents || provider.studentRecords.isEmpty) &&
        (!showTeachers || provider.teacherRecords.isEmpty);

    if (hasNoRecords) {
      return Container(
        height: 400,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outline,
                size: 48,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No attendance records found',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No attendance data available for the selected course and role filter',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Stats
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 24),
          child: Row(
            children: [
              if (showStudents)
                _buildStatCard(
                  context,
                  title: 'Students',
                  total: provider.studentRecords.length,
                  present: provider.studentRecords
                      .where((r) => r.status == AttendanceStatus.present)
                      .length,
                  color: Colors.green,
                  icon: Icons.school,
                ),
              if (showStudents && showTeachers) const SizedBox(width: 16),
              if (showTeachers)
                _buildStatCard(
                  context,
                  title: 'Teachers',
                  total: provider.teacherRecords.length,
                  present: provider.teacherRecords
                      .where((r) => r.status == AttendanceStatus.present)
                      .length,
                  color: Colors.blue,
                  icon: Icons.person,
                ),
            ],
          ),
        ),

        // Attendance Tables
        Column(
          children: [
            if (showStudents && provider.studentRecords.isNotEmpty)
              _buildRoleAttendanceTable(
                context,
                title: 'Student Attendance',
                records: provider.studentRecords,
                color: Colors.green,
                icon: Icons.school,
              ),
            if (showStudents && showTeachers &&
                provider.studentRecords.isNotEmpty &&
                provider.teacherRecords.isNotEmpty)
              const SizedBox(height: 32),
            if (showTeachers && provider.teacherRecords.isNotEmpty)
              _buildRoleAttendanceTable(
                context,
                title: 'Teacher Attendance',
                records: provider.teacherRecords,
                color: Colors.blue,
                icon: Icons.person,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      BuildContext context, {
        required String title,
        required int total,
        required int present,
        required Color color,
        required IconData icon,
      }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final percentage = total > 0 ? (present / total * 100).round() : 0;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 24, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '$present/$total present',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$percentage%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: total > 0 ? present / total : 0,
              backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              color: color,
              borderRadius: BorderRadius.circular(4),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Attendance Rate',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  '$present out of $total',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleAttendanceTable(
      BuildContext context, {
        required String title,
        required List<AttendanceRecord> records,
        required Color color,
        required IconData icon,
      }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.grey.shade800,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${records.length} ${records.length == 1 ? 'record' : 'records'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Total: ${records.length}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Table with horizontal scrolling
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width - 48,
              ),
              child: DataTable(
                columnSpacing: 32,
                horizontalMargin: 24,
                dividerThickness: 1,
                dataRowHeight: 60,
                headingRowHeight: 56,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                    ),
                  ),
                ),
                columns: const [
                  DataColumn(label: _TableHeader(text: 'Name')),
                  DataColumn(label: _TableHeader(text: 'Role')),
                  DataColumn(label: _TableHeader(text: 'Program')),
                  DataColumn(label: _TableHeader(text: 'Year')),
                  DataColumn(label: _TableHeader(text: 'Course')),
                  DataColumn(label: _TableHeader(text: 'Time')),
                  DataColumn(label: _TableHeader(text: 'Status')),
                  DataColumn(label: _TableHeader(text: 'Device')),
                ],
                rows: records.map((record) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          record.personName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white : Colors.grey.shade800,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: record.role == 'Student'
                                ? Colors.green.withOpacity(0.1)
                                : Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            record.role,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: record.role == 'Student' ? Colors.green : Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 200,
                          child: Text(
                            record.program,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Year ${record.year}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: isDarkMode ? Colors.white : Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 180,
                          child: Text(
                            record.course,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.white : Colors.grey.shade800,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${record.time.hour.toString().padLeft(2, '0')}:${record.time.minute.toString().padLeft(2, '0')}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: record.status == AttendanceStatus.present
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: record.status == AttendanceStatus.present
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                record.status == AttendanceStatus.present
                                    ? Icons.check_circle
                                    : Icons.schedule,
                                size: 16,
                                color: record.status == AttendanceStatus.present
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                record.status == AttendanceStatus.present
                                    ? 'Present'
                                    : 'Late',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: record.status == AttendanceStatus.present
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 150,
                          child: Text(
                            record.device,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;

  const _TableHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade600,
        fontSize: 12,
        letterSpacing: 0.5,
      ),
    );
  }
}