import 'package:flutter/material.dart';
import 'package:frontend_ui/features/programs/course_form_screen.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/app_scaffold.dart';
import 'course_provider.dart';
import 'course_model.dart';
import 'program_provider.dart';



class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CoursesScreen> {
  bool _isDeleteMode = false;
  Set<String> _selectedCourseIds = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CourseProvider>().loadCourses();
    });
  }

  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final courses = provider.courses;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final totalCourses = courses.length;
    final totalPrograms = courses
        .expand((c) => c.programNames ?? c.programIds)
        .where((name) => name.isNotEmpty).toSet().length;

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
                      'Courses',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage academic courses and assignments',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add Subject'),
                  onPressed: () {
                    showDialog(context: context, builder: (_) => CourseFormScreen(),);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    label: 'Total Courses',
                    value: '$totalCourses',
                    color: Colors.blue,
                    icon: Icons.subject,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    label: 'Programs',
                    value: '$totalPrograms',
                    color: Colors.green,
                    icon: Icons.person,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_isDeleteMode)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: Text('Delete (${_selectedCourseIds.length})'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: _selectedCourseIds.isEmpty
                        ? null
                        : () async {
                      await context
                          .read<CourseProvider>()
                          .bulkDeleteCourses(_selectedCourseIds.toList());
                      setState(() {
                        _isDeleteMode = false;
                        _selectedCourseIds.clear();
                      });
                    }
                  ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: Icon(_isDeleteMode ? Icons.close : Icons.delete_outline),
                  label: Text(_isDeleteMode ? 'Cancel': 'Delete'),
                  onPressed: () {
                    setState(() {
                      _isDeleteMode = !_isDeleteMode;
                      _selectedCourseIds.clear();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Courses Table
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                  children: [
                    if (_isDeleteMode)
                      const SizedBox(width: 40),
                    // Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
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
                          const Expanded(
                            flex: 2,
                            child: _TableHeader(text: 'Course'),
                          ),
                          const Expanded(
                            child: _TableHeader(text: 'Code'),
                          ),
                          const Expanded(
                            flex: 2,
                            child: _TableHeader(text: 'Program'),
                          ),
                          const Expanded(
                            child: _TableHeader(text: 'Year / Semester'),
                          ),
                          const Expanded(
                            child: _TableHeader(text: 'Qualification'),
                          ),
                          Container(
                            width: 80,
                            alignment: Alignment.center,
                            child: const _TableHeader(text: 'Actions'),
                          ),
                        ],
                      ),
                    ),

                    // Table Content
                    Expanded(
                      child: courses.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.subject_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No courses found',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add your first course to get started',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      )
                          : ListView.builder(
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          final course = courses[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                if (_isDeleteMode)
                                  SizedBox(
                                    width: 40,
                                    child: Checkbox(
                                      value: _selectedCourseIds.contains(course.id),
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            _selectedCourseIds.add(course.id!);
                                          } else {
                                            _selectedCourseIds.remove(course.id);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: _getSubjectColor(index).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          _getSubjectIcon(course.name),
                                          color: _getSubjectColor(index),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              course.name,
                                              style: theme.textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: isDarkMode ? Colors.white : Colors.grey.shade800,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Course ID: ${course.id ?? 'N/A'}',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.blue.withOpacity(0.3),
                                              ),
                                            ),
                                            child: Text(
                                              course.code,
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: Text(
                                      course.programAbbreviations.isNotEmpty
                                          ? course.programAbbreviations.join(', ')
                                          : '-',
                                      style: theme.textTheme.bodyMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Year ${course.year}",
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: isDarkMode ? Colors.white : Colors.grey.shade800,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "semester: ${course.semester}",
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.purple.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        course.qualification,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: Colors.purple,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  width: 80,
                                  child: Center(
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.edit, size: 18),
                                        color: Colors.orange,
                                        onPressed: () async {
                                          await Provider.of<ProgramProvider>(context, listen: false)
                                              .loadPrograms();
                                          showDialog(
                                            context: context,
                                            builder: (_) => CourseFormScreen(
                                              existingCourse: course,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
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
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getSubjectColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }

  IconData _getSubjectIcon(String subjectName) {
    final name = subjectName.toLowerCase();

    if (name.contains('math')) return Icons.calculate;
    if (name.contains('science')) return Icons.science;
    if (name.contains('english') || name.contains('language')) return Icons.language;
    if (name.contains('history') || name.contains('social')) return Icons.history_edu;
    if (name.contains('art')) return Icons.palette;
    if (name.contains('music')) return Icons.music_note;
    if (name.contains('physics')) return Icons.speed;
    if (name.contains('chemistry')) return Icons.science_outlined;
    if (name.contains('biology')) return Icons.psychology;
    if (name.contains('geography')) return Icons.public;
    if (name.contains('computer') || name.contains('tech')) return Icons.computer;
    if (name.contains('physical') || name.contains('pe')) return Icons.sports;
    if (name.contains('business') || name.contains('economics')) return Icons.business;

    return Icons.subject;
  }
}

class _TableHeader extends StatelessWidget {
  final String text;

  const _TableHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.grey,
        fontSize: 13,
      ),
      textAlign: TextAlign.center,
    );
  }
}