import 'package:flutter/material.dart';
import 'package:frontend_ui/features/programs/program_model.dart';
import 'course_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'program_provider.dart';
import 'course_provider.dart';

class CourseFormScreen extends StatefulWidget {
  final Course? existingCourse;

  const CourseFormScreen({super.key, this.existingCourse});

  @override
  State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _departmentController;

  String? _selectedProgramId;
  String? _selectedQualification;
  int? _selectedYear;
  int? _selectedSemester;

  List<int> _availableYears = [];

  final semesters = [1, 2];



  bool get isEditing => widget.existingCourse != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existingCourse?.name ?? '');
    _codeController =
        TextEditingController(text: widget.existingCourse?.code ?? '');
    _departmentController =
        TextEditingController(text: widget.existingCourse?.department ?? '');
    _selectedQualification =
        widget.existingCourse?.qualification;
    _selectedProgramId =
        widget.existingCourse?.programId;
    _selectedYear =
        widget.existingCourse?.year;
    _selectedSemester =
        widget.existingCourse?.semester;

    if (widget.existingCourse != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final programProvider = Provider.of<ProgramProvider>(context, listen: false);

        final selectedProgram = programProvider.programs
            .where((p) => p.id == _selectedProgramId)
            .toList();

        if (selectedProgram.isNotEmpty) {
          _availableYears = List.generate(
            selectedProgram.first.duration,
                (index) => index + 1,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final programProvider = Provider.of<ProgramProvider>(context);
    final allPrograms = programProvider.programs;

    final List<String> qualifications = allPrograms
        .map((p) => p.qualification.name) // 👈 convert enum to String
        .toSet()
        .toList();

    final filteredPrograms = allPrograms
      .where((p) => p.qualification.name == _selectedQualification)
      .toList();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isEditing
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit : Icons.subject,
                      color: isEditing ? Colors.orange : Colors.purple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Edit Course' : 'Add New Course',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isEditing
                              ? 'Update course information'
                              : 'Fill in the course details below',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Form Fields
              Column(
                children: [
                  _buildTextField(
                    context: context,
                    controller: _nameController,
                    label: 'Course Name',
                    hintText: 'Enter Course name (e.g., Mathematics)',
                    icon: Icons.subject,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Course name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    context: context,
                    controller: _codeController,
                    label: 'Course Code',
                    hintText: 'Enter Course code (e.g., MATH101)',
                    icon: Icons.code,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Course code is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: qualifications.contains(_selectedQualification)
                        ? _selectedQualification
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Qualification',
                      border: OutlineInputBorder(),
                    ),
                    items: qualifications
                        .map((q) => DropdownMenuItem<String>(
                      value: q,
                      child: Text(q),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedQualification = value;
                        _selectedProgramId = null;
                        _selectedYear = null;
                        _availableYears = [];
                      });
                    },
                    validator: (value) =>
                    value == null ? 'Select qualification' : null,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedProgramId,
                    decoration: const InputDecoration(
                      labelText: 'Program',
                      border: OutlineInputBorder(),
                    ),
                    items: filteredPrograms
                      .map((program) => DropdownMenuItem(
                      value: program.id,
                      child: Text(program.name),
                    )).toList(),
                    onChanged: (value) {
                      final selectedProgram = filteredPrograms.firstWhere((p) => p.id == value);

                      setState(() {
                        _selectedProgramId = value;

                        _availableYears = List.generate(
                            selectedProgram.duration,
                                (index) => index + 1);
                        _selectedYear = null;
                      });
                    },
                    validator: (value) => value == null ? 'Select program' : null,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<int>(
                    value: _selectedYear,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                    ),
                    items: _availableYears
                      .map((year) => DropdownMenuItem(
                      value: year,
                      child: Text("Year $year"),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value;
                      });
                    },
                    validator: (value) => value == null ? 'Select year': null,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<int>(
                    value: _selectedSemester,
                    decoration: const InputDecoration(
                      labelText: 'Semester',
                      border: OutlineInputBorder(),
                    ),
                    items: semesters
                      .map((sem) => DropdownMenuItem(
                      value: sem,
                      child: Text("Semester $sem"),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSemester = value;
                      });
                    },
                    validator: (value) => value == null ? 'Select semester' : null,
                  )
                ],
              ),

              const SizedBox(height: 40),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      'Cancel',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final provider = Provider.of<CourseProvider>(context, listen: false);
                        final course = Course(
                          id: widget.existingCourse?.id ?? '',
                          name: _nameController.text,
                          code: _codeController.text,
                          qualification: _selectedQualification!,
                          programId: _selectedProgramId!,
                          department: _departmentController.text,
                          semester: _selectedSemester!,
                          year: _selectedYear!,
                        );

                        try {
                          if (isEditing) {
                            await provider.updateCourse(course);
                          } else {
                            await provider.addCourse(course);
                          }

                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: $e")),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEditing ? Colors.orange : Colors.purple,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isEditing ? Icons.save : Icons.add,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isEditing ? 'Update Course' : 'Add Course',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    required String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.white,
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  icon,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              errorStyle: TextStyle(
                color: Colors.red.shade600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required BuildContext context,
    required String? value,
    required String label,
    required String hintText,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
    required String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.white,
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  icon,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
            items: items
                .map((teacher) => DropdownMenuItem(
              value: teacher,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    teacher,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ))
                .toList(),
            onChanged: onChanged,
            validator: validator,
            style: theme.textTheme.bodyMedium,
            dropdownColor: Colors.white,
            icon: Icon(
              Icons.arrow_drop_down,
              color: Colors.grey.shade600,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }
}