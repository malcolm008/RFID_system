import 'package:flutter/material.dart';
import 'program_model.dart';

class ProgramFormScreen extends StatefulWidget {
  final Program? existingProgram;

  const ProgramFormScreen({super.key, this.existingProgram});

  @override
  State<ProgramFormScreen> createState() => _ProgramFormScreenState();
}

class _ProgramFormScreenState extends State<ProgramFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  ProgramLevel? _selectedLevel;
  Qualification? _selectedQualification;

  bool get isEditing => widget.existingProgram != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existingProgram?.name ?? '');

    _selectedLevel = widget.existingProgram?.level;
    _selectedQualification = widget.existingProgram?.qualification;
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
                    label: 'Class Name',
                    hintText: 'Enter class name (e.g., Grade 10A)',
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
                      validator: (value) =>
                      value == null ? 'Please select level' : null,
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (isEditing) {
                          // provider.updateClass(...)
                        } else {
                          // provider.addClass(...)
                        }
                        Navigator.pop(context);
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