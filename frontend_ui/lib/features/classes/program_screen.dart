import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/app_scaffold.dart';
import 'program_provider.dart';
import 'program_form_screen.dart';

class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProgramProvider>();
    final classes = provider.programs;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

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
                      'Programs',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage programs and academic levels',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add Program'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const ProgramFormScreen(),
                    );
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
                    label: 'Total Programs',
                    value: '${classes.length}',
                    color: Colors.blue,
                    icon: Icons.class_,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    label: 'Undergraduate Level',
                    value: '${classes.where((c) => c.level.toLowerCase().contains('undergraduate')).length}',
                    color: Colors.green,
                    icon: Icons.school,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    label: 'Postgraduate Level',
                    value: '${classes.where((c) => c.level.toLowerCase().contains('postgraduate')).length}',
                    color: Colors.orange,
                    icon: Icons.school_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Classes Table
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
                            child: _TableHeader(text: 'Program Name'),
                          ),
                          const Expanded(
                            child: _TableHeader(text: 'Level'),
                          ),
                          const Expanded(
                            child: _TableHeader(text: 'Department'),
                          ),
                          const Expanded(
                            child: _TableHeader(text: 'Duration'),
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
                      child: classes.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.class_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No programs found',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add your first program to get started',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      )
                          : ListView.builder(
                        itemCount: classes.length,
                        itemBuilder: (context, index) {
                          final classItem = classes[index];
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
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: _getLevelColor(classItem.level).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.class_,
                                          color: _getLevelColor(classItem.level),
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              classItem.name,
                                              style: theme.textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: isDarkMode ? Colors.white : Colors.grey.shade800,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Program ID: ${classItem.id ?? 'N/A'}',
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
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: _getLevelColor(classItem.level).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: _getLevelColor(classItem.level).withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          classItem.level,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: _getLevelColor(classItem.level),
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            classItem.department,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: isDarkMode ? Colors.white : Colors.grey.shade800,
                                            ),
                                          )
                                        ],
                                      ),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            classItem.duration,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: isDarkMode ? Colors.white : _getLevelColor(classItem.level),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 80,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.edit, size: 18),
                                          color: Colors.blue,
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => ClassFormScreen(existingClass: classItem),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
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

  Color _getLevelColor(String level) {
    final levelLower = level.toLowerCase();
    if (levelLower.contains('undergraduate')) {
      return Colors.green;
    } else if (levelLower.contains('postgraduate')) {
      return Colors.orange;
    } else if (levelLower.contains('primary') || levelLower.contains('kindergarten')) {
      return Colors.purple;
    } else if (levelLower.contains('secondary')) {
      return Colors.blue;
    } else if (levelLower.contains('high')) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
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