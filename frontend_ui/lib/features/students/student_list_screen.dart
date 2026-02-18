import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/app_scaffold.dart';
import 'student_provider.dart';
import 'student_form_screen.dart';
import 'student_model.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();

}

class _StudentListScreenState extends State<StudentListScreen> {
  bool _isDeleteMode = false;
  Set<String> _selectedStudentIds = {};
  String searchQuery = '';
  int? selectedYear;
  String? selectedProgram;
  bool? filterRfid;
  bool? filterFingerprint;

  List<Student> _filteredStudents(List<Student> students) {
    return students.where((s) {
      final matchesSearch =
          s.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              s.regNumber.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesYear =
          selectedYear == null || s.year == selectedYear;

      final matchesProgram =
          selectedProgram == null || s.program == selectedProgram;

      final matchesRfid =
          filterRfid == null || s.hasRfid == filterRfid;

      final matchesFingerprint =
          filterFingerprint == null ||
              s.hasFingerprint == filterFingerprint;

      return matchesSearch &&
          matchesYear &&
          matchesProgram &&
          matchesRfid &&
          matchesFingerprint;
    }).toList();
  }


  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<StudentProvider>().loadStudents();
    });
  }


  Widget build(BuildContext context) {
    final allStudents = context.watch<StudentProvider>().students;
    final students = _filteredStudents(allStudents);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AppScaffold(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(1),
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
                        'Students',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage student records and enrollment',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Add Student'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const StudentFormDialog(),
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
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: 260,
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Search name or reg no',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => searchQuery = value);
                        },
                      ),
                    ),
                    DropdownButton<int?>(
                      value: selectedYear,
                      hint: const Text('Year'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Years')),
                        ...{...allStudents.map((s) => s.year)}.map(
                              (year)=> DropdownMenuItem(
                            value: year,
                            child: Text('Year $year'),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => selectedYear = value);
                      },
                    ),

                    DropdownButton<String?>(
                      value: selectedProgram,
                      hint: const Text('Program'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Programs')),
                        ...{...allStudents.map((s) => s.program)}.map(
                              (program) => DropdownMenuItem(
                            value: program,
                            child: Text(program),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => selectedProgram = value);
                      },
                    ),

                    DropdownButton<bool?>(
                      value: filterRfid,
                      hint: const Text('RFID'),
                      items: const[
                        DropdownMenuItem(
                          value: null,
                          child: Text('All RFID'),
                        ),
                        DropdownMenuItem(
                          value: true,
                          child: Text('With RFID'),
                        ),
                        DropdownMenuItem(value: false, child: Text('Without RFID')),
                      ],
                      onChanged: (value) {
                        setState(() => filterRfid = value);
                      },
                    ),

                    DropdownButton<bool?>(
                      value: filterFingerprint,
                      hint: const Text('Fingerprint'),
                      items: const [
                        DropdownMenuItem(
                          value: null,
                          child: Text('All Fingerprint'),
                        ),
                        DropdownMenuItem(
                          value: true,
                          child: Text('With FIngerprint'),
                        ),
                        DropdownMenuItem(
                          value: false,
                          child: Text('Without FIngerprint'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => filterFingerprint = value);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Stats Summary
              Container(
                padding: const EdgeInsets.all(10),
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
                      label: 'Total Students',
                      value: '${students.length}',
                      color: Colors.blue,
                      icon: Icons.people,
                    ),
                    _buildStatItem(
                      context: context,
                      label: 'With RFID',
                      value: '${students.where((s) => s.hasRfid).length}',
                      color: Colors.green,
                      icon: Icons.credit_card,
                    ),
                    _buildStatItem(
                      context: context,
                      label: 'With Fingerprint',
                      value: '${students.where((s) => s.hasFingerprint).length}',
                      color: Colors.purple,
                      icon: Icons.fingerprint,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_isDeleteMode)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete),
                      label: Text('Delete (${_selectedStudentIds.length})'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: _selectedStudentIds.isEmpty
                          ? null
                          : () async {
                        await context.read<StudentProvider>().bulkDeleteStudents(_selectedStudentIds.toList());
                        setState(() {
                    )
                ],
              )

              // Students Table
              SizedBox(
                height: 600,
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
                            Expanded(child: _TableHeader(text: 'Reg No')),
                            Expanded(flex: 2, child: _TableHeader(text: 'Name')),
                            Expanded(child: _TableHeader(text: 'Program')),
                            Expanded(child: _TableHeader(text: 'Year')),
                            Expanded(child: _TableHeader(text: 'RFID')),
                            Expanded(child: _TableHeader(text: 'Fingerprint')),
                            Expanded(child: _TableHeader(text: 'Actions')),
                          ],
                        ),
                      ),

                      // Table Content
                      Expanded(
                        child: students.isEmpty
                            ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No students found',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add your first student to get started',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        )
                            : SingleChildScrollView(
                          child: Column(
                            children: students.map((s) {
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
                                      flex:1,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          s.regNumber,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              s.name,
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: isDarkMode ? Colors.white : Colors.grey.shade800,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
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
                                          s.program,
                                          style: theme.textTheme.bodyMedium,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 6),
                                        child: Text(
                                          "Year ${s.year}",
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: isDarkMode ? Colors.white : Colors.grey.shade800,
                                          ),
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
                                                color: s.hasRfid
                                                    ? Colors.green.withOpacity(0.1)
                                                    : Colors.red.withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                s.hasRfid ? Icons.check : Icons.close,
                                                size: 18,
                                                color: s.hasRfid ? Colors.green : Colors.red,
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
                                                color: s.hasFingerprint
                                                    ? Colors.green.withOpacity(0.1)
                                                    : Colors.red.withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                s.hasFingerprint ? Icons.check : Icons.close,
                                                size: 18,
                                                color: s.hasFingerprint ? Colors.green : Colors.red,
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
                                                color: Colors.blue.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(Icons.edit, size: 18),
                                                color: Colors.blue,
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) => StudentFormDialog(student: s),
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
          width: 40,
          height: 40,
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
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10,
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
        fontWeight: FontWeight.w600,
        color: Colors.grey,
        fontSize: 13,
      ),
      textAlign: TextAlign.center,
    );
  }
}