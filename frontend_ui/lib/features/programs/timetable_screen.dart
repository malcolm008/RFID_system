// lib/features/programs/timetable_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/app_scaffold.dart';
import 'timetable_provider.dart';
import 'timetable_form_screen.dart';
import 'timetable_model.dart';
import '../programs/program_provider.dart';
import '../teachers/teacher_provider.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

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

            // Stats cards (same as before)
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
                    width: 200,
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
                            child: Text(p.name),
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
                    width: 120,
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
                    width: 200,
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
                                return Container(
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
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.course,
            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            entry.teacherName,
            style: theme.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${entry.startTime} - ${entry.endTime}',
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
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