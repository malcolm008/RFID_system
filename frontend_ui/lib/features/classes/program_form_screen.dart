import 'package:flutter/material.dart';
import 'program_model.dart';
import 'package:provider/provider.dart';
import 'program_provider.dart';
import 'package:http/http.dart' as http;

class ProgramFormScreen extends StatefulWidget {
  final Program? existingProgram;

  const ProgramFormScreen({super.key, this.existingProgram});

  @override
  State<ProgramFormScreen> createState() => _ProgramFormScreenState();
}

class _ProgramFormScreenState extends State<ProgramFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _departmentController;

  ProgramLevel? _selectedLevel;
  Qualification? _selectedQualification;
  String? _selectedDuration;

  bool get isEditing => widget.existingProgram != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingProgram?.name ?? '');
    _departmentController = TextEditingController(text: widget.existingProgram?.department ?? '');

    _selectedLevel = widget.existingProgram?.level;
    _selectedQualification = widget.existingProgram?.qualification;
    _selectedDuration = widget.existingProgram?.duration;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  final Map<Qualification, List<ProgramLevel>> qualificationLevels = {
    Qualification.Certificate: [],
    Qualification.Diploma: [],
    Qualification.Degree: [
      ProgramLevel.undergraduate,
      ProgramLevel.postgraduate,
    ],
    Qualification.Masters: [
      ProgramLevel.postgraduate,
    ],
    Qualification.PhD: [
      ProgramLevel.postgraduate,
    ]
  };

  final Map<Qualification, List<String>> qualificationDurations = {
    Qualification.Certificate: [
      '6 months',
      '1 year',
    ],
    Qualification.Diploma: [
      '1 year',
      '2 years',
    ],
    Qualification.Degree: [
      '3 years',
      '4 years',
    ],
    Qualification.Masters: [
      '1 year',
      '2 years',
    ],
    Qualification.PhD: [
      '3 years',
      '4 years',
      '5 years',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                          : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit : Icons.class_,
                      color: isEditing ? Colors.orange : Colors.blue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Edit Class' : 'Add New Class',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isEditing
                              ? 'Update class information'
                              : 'Fill in the class details below',
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
                    label: 'Program',
                    hintText: 'Enter program name (e.g. Bsc.Computer Science)',
                    icon: Icons.class_,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Class name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<Qualification>(
                    value: _selectedQualification,
                    decoration: const InputDecoration(labelText: 'Qualification'),
                    items: Qualification.values.map((q) {
                      return DropdownMenuItem(
                        value: q,
                        child: Text(q.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedQualification = value;
                        _selectedLevel = null;
                        _selectedDuration = null;
                      });
                    },
                    validator: (value) => value == null ? 'Please select qualification' : null,
                  ),
                  const SizedBox(height: 16),
                  if (qualificationLevels.containsKey(_selectedQualification))
                    DropdownButtonFormField<ProgramLevel>(
                      value: _selectedLevel,
                      decoration: const InputDecoration(labelText: 'Program Level'),
                      items: qualificationLevels[_selectedQualification]!
                          .map((level) => DropdownMenuItem(
                        value: level,
                        child: Text(level.name),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedLevel = value);
                      },
                    ),
                  const SizedBox(height: 16),
                  if (_selectedQualification != null)
                    DropdownButtonFormField<String>(
                      value: _selectedDuration,
                      decoration: const InputDecoration(labelText: 'Duration'),
                      items: qualificationDurations[_selectedQualification]!
                        .map((duration) => DropdownMenuItem(
                        value: duration,
                        child: Text(duration),
                      )).toList(),
                      onChanged: (value) {
                        setState(() => _selectedDuration = value);
                      },
                      validator: (value) => value == null ? 'Please select duration': null,
                    ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    context: context,
                    controller: _departmentController,
                    label: 'Department',
                    hintText: 'Enter the department',
                    icon: Icons.corporate_fare,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Department name is required';
                      }
                      return null;
                    },
                  ),
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
                    onPressed: ()  async {
                      if (!_formKey.currentState!.validate()) return;

                      if(_selectedQualification == null) return;
                      if(_selectedDuration == null) return;

                      final provider = context.read<ProgramProvider>();

                      final program = Program(
                        id: isEditing
                            ? widget.existingProgram!.id
                            : DateTime.now().millisecondsSinceEpoch.toString(),
                        name: _nameController.text.trim(),
                        qualification: _selectedQualification!,
                        level: _selectedLevel,
                        duration: _selectedDuration!,
                        department: _departmentController.text.trim(),
                      );

                      try {
                        if (isEditing) {
                          await provider.updateProgram(program);
                        } else {
                          await provider.addProgram(program);
                        }
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEditing ? Colors.orange : Colors.blue,
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
                          isEditing ? 'Update Class' : 'Add Class',
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
}