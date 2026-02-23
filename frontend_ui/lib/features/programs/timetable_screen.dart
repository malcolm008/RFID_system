// lib/features/programs/timetable_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/app_scaffold.dart';
import 'timetable_provider.dart';
import 'timetable_form_screen.dart';
import 'timetable_model.dart';
import '../programs/program_provider.dart';
import '../teachers/teacher_provider.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      debugPrint('Loading timetable data on screen init');
      context.read<TimetableProvider>().loadTimetable();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.watch<TimetableProvider>();
    debugPrint('Entries count: ${provider.entries.length}');
  }

  // Show entry details dialog with edit/delete options
  void _showEntryDetails(BuildContext context, TimetableEntry entry) {
    final theme = Theme.of(context);
    final timetableProvider = Provider.of<TimetableProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.schedule, color: Colors.blue.shade700),
              ),
              const SizedBox(width: 12),
              const Text('Schedule Details'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Program', entry.program),
                _buildDetailRow('Course', entry.course),
                _buildDetailRow('Teacher', entry.teacherName),
                _buildDetailRow('Day', entry.day),
                _buildDetailRow('Time', '${entry.startTime} - ${entry.endTime}'),
                _buildDetailRow('Year', 'Year ${entry.year}'),
                _buildDetailRow('Qualification', entry.qualification),
                if (entry.location.isNotEmpty) _buildDetailRow('Location', entry.location),
                if (entry.device.isNotEmpty) _buildDetailRow('Device', entry.device),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context); // Close details dialog
                // Open edit form with existing entry
                showDialog(
                  context: context,
                  builder: (_) => TimetableFormScreen(existingEntry: entry),
                );
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                // Confirm delete
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm Delete'),
                      content: Text('Are you sure you want to delete this schedule for ${entry.course}?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  },
                );

                if (confirm == true) {
                  Navigator.pop(context); // Close details dialog
                  try {
                    await timetableProvider.deleteEntry(entry.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Schedule deleted successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error deleting schedule: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              icon: const Icon(Icons.delete, size: 18),
              label: const Text('Delete'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper widget for detail rows
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timetableProvider = context.watch<TimetableProvider>();
    final programProvider = context.watch<ProgramProvider>();
    final teacherProvider = context.watch<TeacherProvider>();

    final entries = timetableProvider.entries;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    // Group entries by day
    final Map<String, List<TimetableEntry>> groupedByDay = {};
    for (var day in daysOfWeek) {
      groupedByDay[day] = entries.where((e) => e.day == day).toList();
    }

    return AppScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
                      'Timetable',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Weekly class schedule',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add Schedule'),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const TimetableFormScreen(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Stats cards
            Row(
              children: [
                _buildStatCard(
                  context: context,
                  label: 'Total Schedules',
                  value: '${entries.length}',
                  color: Colors.blue,
                  icon: Icons.schedule,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  context: context,
                  label: 'Unique Classes',
                  value: '${entries.map((e) => e.program).toSet().length}',
                  color: Colors.green,
                  icon: Icons.class_,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  context: context,
                  label: 'Active Teachers',
                  value: '${entries.map((e) => e.teacherName).toSet().length}',
                  color: Colors.orange,
                  icon: Icons.people,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Filter Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Program filter
                  Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    child: DropdownButtonFormField<int?>(
                      value: timetableProvider.filterProgramId,
                      hint: const Text('All Programs'),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('All Programs'),
                        ),
                        ...programProvider.programs.map((p) {
                          return DropdownMenuItem<int?>(
                            value: int.tryParse(p.id),
                            child: Text(p.abbreviation),
                          );
                        }).toList(),
                      ],
                      onChanged: (val) => timetableProvider.setProgramFilter(val),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),

                  // Year filter
                  Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 12),
                    child: DropdownButtonFormField<int?>(
                      value: timetableProvider.filterYear,
                      hint: const Text('Year'),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('All Years'),
                        ),
                        for (int y = 1; y <= 4; y++)
                          DropdownMenuItem<int?>(
                            value: y,
                            child: Text('Year $y'),
                          ),
                      ],
                      onChanged: (val) => timetableProvider.setYearFilter(val),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),

                  // Teacher filter
                  Container(
                    width: 230,
                    margin: const EdgeInsets.only(right: 12),
                    child: DropdownButtonFormField<int?>(
                      value: timetableProvider.filterTeacherId,
                      hint: const Text('All Teachers'),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('All Teachers'),
                        ),
                        ...teacherProvider.teachers.map((t) {
                          return DropdownMenuItem<int?>(
                            value: int.tryParse(t.id),
                            child: Text(t.name),
                          );
                        }).toList(),
                      ],
                      onChanged: (val) => timetableProvider.setTeacherFilter(val),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),

                  // Day filter
                  Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 12),
                    child: DropdownButtonFormField<String?>(
                      value: timetableProvider.filterDay,
                      hint: const Text('All Days'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Days'),
                        ),
                        ...daysOfWeek.map((d) {
                          return DropdownMenuItem<String?>(
                            value: d,
                            child: Text(d),
                          );
                        }).toList(),
                      ],
                      onChanged: (val) => timetableProvider.setDayFilter(val),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),

                  // Clear button
                  TextButton.icon(
                    onPressed: timetableProvider.clearFilters,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Calendar Grid
            Expanded(
              child: timetableProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : entries.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No schedules found',
                      style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Adjust filters or add new schedules',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
                    ),
                  ],
                ),
              )
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: daysOfWeek.length * 200.0,
                  child: Column(
                    children: [
                      // Day headers
                      Row(
                        children: daysOfWeek.map((day) {
                          return Container(
                            width: 200,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _getDayColor(day).withOpacity(0.1),
                              border: Border(
                                right: BorderSide(color: Colors.grey.shade300),
                                bottom: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Text(
                              day,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getDayColor(day),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }).toList(),
                      ),
                      // Time slots (8am to 8pm)
                      Expanded(
                        child: ListView.builder(
                          itemCount: 12,
                          itemBuilder: (context, slotIndex) {
                            final hour = 8 + slotIndex;
                            final timeLabel = '${hour.toString().padLeft(2, '0')}:00';
                            return Row(
                              children: daysOfWeek.map((day) {
                                final dayEntries = groupedByDay[day] ?? [];
                                final matching = dayEntries.where(
                                        (e) => e.startTime.startsWith('${hour.toString().padLeft(2, '0')}:')
                                );
                                final entry = matching.isNotEmpty ? matching.first : null;
                                return GestureDetector(
                                  onTap: entry != null ? () => _showEntryDetails(context, entry) : null,
                                  child: Container(
                                    width: 200,
                                    height: 70,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(color: Colors.grey.shade300),
                                        bottom: BorderSide(color: Colors.grey.shade300),
                                      ),
                                    ),
                                    child: entry != null
                                        ? _buildEntryCard(entry, theme)
                                        : Text(
                                      timeLabel,
                                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryCard(TimetableEntry entry, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2),
      height: 68,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              entry.course,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 1),
          Flexible(
            child: Text(
              entry.teacherName,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 1),
          Flexible(
            child: Text(
              '${entry.startTime} - ${entry.endTime}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 9,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required BuildContext context, required String label, required String value, required Color color, required IconData icon}) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: color)),
                  const SizedBox(height: 4),
                  Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDayColor(String day) {
    switch (day) {
      case 'Monday': return Colors.blue;
      case 'Tuesday': return Colors.green;
      case 'Wednesday': return Colors.orange;
      case 'Thursday': return Colors.purple;
      case 'Friday': return Colors.red;
      case 'Saturday': return Colors.teal;
      case 'Sunday': return Colors.pink;
      default: return Colors.grey;
    }
  }
}