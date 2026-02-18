import 'package:flutter/material.dart';
import 'package:frontend_ui/features/programs/program_model.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/app_scaffold.dart';
import 'program_provider.dart';
import 'program_form_screen.dart';

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  bool _isDeleteMode = false;
  Set<String> _selectedProgramIds = {};

  @override
  void initState(){
    super.initState();

    Future.microtask(() {
      context.read<ProgramProvider>().loadPrograms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProgramProvider>();
    final programs = provider.programs;
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
                const SizedBox(width: 12),
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
                    value: '${programs.length}',
                    color: Colors.blue,
                    icon: Icons.class_,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    label: 'Certificate',
                    value: '${programs.where((c) => c.qualification == Qualification.Certificate).length}',
                    color: Colors.deepPurpleAccent,
                    icon: Icons.school,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    label: 'Diploma',
                    value: '${programs.where((c) => c.qualification == Qualification.Diploma).length}',
                    color: Colors.pinkAccent,
                    icon: Icons.school_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    label: 'Degree',
                    value: '${programs.where((c) => c.qualification == Qualification.Degree).length}',
                    color: Colors.teal,
                    icon: Icons.school,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    label: 'Masters',
                    value: '${programs.where((c) => c.qualification == Qualification.Masters).length}',
                    color: Colors.cyanAccent,
                    icon: Icons.school_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    label: 'PhD',
                    value: '${programs.where((c) => c.qualification == Qualification.PhD).length}',
                    color: Colors.brown,
                    icon: Icons.school,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_isDeleteMode)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: Text('Delete (${_selectedProgramIds.length})'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: _selectedProgramIds.isEmpty
                        ? null
                        : () async {
                      await context.read<ProgramProvider>().bulkDeletePrograms(_selectedProgramIds.toList());
                      setState(() {
                        _isDeleteMode = false;
                        _selectedProgramIds.clear();
                      });
                    },
                  ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: Icon(_isDeleteMode ? Icons.close : Icons.delete_outline),
                  label: Text(_isDeleteMode ? 'Cancel' : 'Delete'),
                  onPressed: () {
                    setState(() {
                      _isDeleteMode = !_isDeleteMode;
                      _selectedProgramIds.clear();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
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
                            child: _TableHeader(text: 'Program'),
                          ),
                          const Expanded(
                            child: _TableHeader(text: 'Qualification'),
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
                      child: programs.isEmpty
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
                        itemCount: programs.length,
                        itemBuilder: (context, index) {
                          final programItem = programs[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            decoration: BoxDecoration(
                              color: _selectedProgramIds.contains(programItem.id)
                                  ? Colors.red.withOpacity(0.05)
                                  : null,
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
                                      value: _selectedProgramIds.contains(programItem.id),
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            _selectedProgramIds.add(programItem.id!);
                                          } else {
                                            _selectedProgramIds.remove(programItem.id);
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
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: _getQualificationColor(programItem.qualification.name).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.class_,
                                          color: _getQualificationColor(programItem.qualification.name),
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              programItem.name,
                                              style: theme.textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: isDarkMode ? Colors.white : Colors.grey.shade800,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Program ID: ${programItem.id ?? 'N/A'}',
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  'Code: ${programItem.abbreviation ?? 'N/A'}',
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                              ],
                                            )

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
                                          color: _getQualificationColor(programItem.qualification.name).withOpacity(0.1),
                                          borderRadius:  BorderRadius.circular(20),
                                          border: Border.all(
                                            color: _getQualificationColor(programItem.qualification.name).withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          programItem.qualification.name,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: _getQualificationColor(programItem.qualification.name),
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
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
                                          color: _getLevelColor(programItem.level?.name ?? 'N/A').withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: _getLevelColor(programItem.level?.name ?? 'N/A').withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          programItem.level?.name ?? 'N/A',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: _getLevelColor(programItem.level?.name ?? 'N/A'),
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
                                        programItem.department,
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
                                            programItem.duration == 1
                                                ? "${programItem.duration} year"
                                                : "${programItem.duration} years",
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : _getQualificationColor(
                                                programItem.qualification.name,
                                              ),
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
                                              builder: (_) => ProgramFormScreen(existingProgram: programItem),
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
    } else {
      return Colors.grey;
    }
  }

  Color _getQualificationColor(String qualification) {
    final qualificationLower = qualification.toLowerCase();
    if (qualificationLower.contains('certificate')) {
      return Colors.deepPurpleAccent;
    } else if (qualificationLower.contains('diploma')) {
      return Colors.pinkAccent;
    } else if (qualificationLower.contains('degree')) {
      return Colors.teal;
    } else if (qualificationLower.contains('masters')) {
      return Colors.cyanAccent;
    } else if (qualificationLower.contains('phd')) {
      return Colors.brown;
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