import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/app_scaffold.dart';
import 'teacher_provider.dart';
import 'teacher_form_dialog.dart';

class TeacherListScreen extends StatelessWidget {
  const TeacherListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teachers = context.watch<TeacherProvider>().teachers;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AppScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Add Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Teachers',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage teaching staff and faculty',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add Teacher'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const TeacherFormDialog(),
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

            // Stats Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    context: context,
                    label: 'Total Teachers',
                    value: '${teachers.length}',
                    color: Colors.blue,
                    icon: Icons.school,
                  ),
                  _buildStatItem(
                    context: context,
                    label: 'With RFID',
                    value: '${teachers.where((t) => t.hasRfid).length}',
                    color: Colors.green,
                    icon: Icons.credit_card,
                  ),
                  _buildStatItem(
                    context: context,
                    label: 'With Fingerprint',
                    value: '${teachers.where((t) => t.hasFingerprint).length}',
                    color: Colors.purple,
                    icon: Icons.fingerprint,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Teachers Table
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
                      child: const Row(
                        children: [
                          Expanded(flex: 1, child: _TableHeader(text: 'Name')),
                          Expanded(flex: 2, child: _TableHeader(text: 'Course')),
                          Expanded(child: _TableHeader(text: 'Program')),
                          Expanded(child: _TableHeader(text: 'RFID')),
                          Expanded(child: _TableHeader(text: 'Fingerprint')),
                          Expanded(child: _TableHeader(text: 'Actions')),
                        ],
                      ),
                    ),

                    // Table Content
                    Expanded(
                      child: teachers.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No teachers found',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add your first teacher to get started',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      )
                          : SingleChildScrollView(
                        child: Column(
                          children: teachers.map((t) {
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
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t.name,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w500,
                                              color: isDarkMode ? Colors.white : Colors.grey.shade800,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            t.email,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                t.course,
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        t.department,
                                        style: theme.textTheme.bodyMedium,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: t.hasRfid
                                                  ? Colors.green.withOpacity(0.1)
                                                  : Colors.red.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              t.hasRfid ? Icons.check : Icons.close,
                                              size: 18,
                                              color: t.hasRfid ? Colors.green : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: t.hasFingerprint
                                                  ? Colors.green.withOpacity(0.1)
                                                  : Colors.red.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              t.hasFingerprint ? Icons.check : Icons.close,
                                              size: 18,
                                              color: t.hasFingerprint ? Colors.green : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: IconButton(
                                              icon: const Icon(Icons.edit, size: 18),
                                              color: Colors.orange,
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (_) => TeacherFormDialog(teacher: t),
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
                            );
                          }).toList(),
                        ),
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

  Widget _buildStatItem({
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
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
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        color: Colors.grey,
        fontSize: 13,
      ),
      textAlign: TextAlign.center,
    );
  }
}