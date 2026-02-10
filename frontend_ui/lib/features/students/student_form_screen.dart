import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'student_model.dart';
import 'student_provider.dart';

class StudentFormDialog extends StatefulWidget {
  final Student? student;
  const StudentFormDialog({super.key, this.student});

  @override
  State<StudentFormDialog> createState() => _StudentFormDialogState();
}

class _StudentFormDialogState extends State<StudentFormDialog> {
  late TextEditingController nameCtrl;
  late TextEditingController regCtrl;
  late TextEditingController progCtrl;
  late int selectedYear;
  late bool hasRfid;
  late bool hasFingerprint;

  @override
  void initState() {
    nameCtrl = TextEditingController(text: widget.student?.name);
    regCtrl = TextEditingController(text: widget.student?.regNumber);
    progCtrl = TextEditingController(text: widget.student?.program);

    selectedYear = widget.student?.year ?? 1;
    hasRfid = widget.student?.hasRfid ?? false;
    hasFingerprint = widget.student?.hasFingerprint ?? false;
    super.initState();
  }

  void _save() async {
    final provider = context.read<StudentProvider>();

    if (nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter student name")),
      );
      return;
    }

    if (regCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter registration number")),
      );
      return;
    }

    if (progCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter program")),
      );
      return;
    }

    try {
      final student = Student(
        id: widget.student?.id ?? '',
        name: nameCtrl.text.trim(),
        regNumber: regCtrl.text.trim(),
        program: progCtrl.text.trim(),
        year: selectedYear,
        hasRfid: hasRfid,
        hasFingerprint: hasFingerprint,
      );

      if (widget.student == null) {
        await provider.addStudent(student);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Student added successfully"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await provider.updateStudent(student);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Student updated successfully"),
            backgroundColor: Colors.orange,
          ),
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
        ),
      );
      print("Error saving student: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.student != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
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
                    isEditing ? Icons.edit : Icons.person_add,
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
                        isEditing ? 'Edit Student' : 'Add New Student',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        isEditing
                            ? 'Update student information'
                            : 'Fill in the student details below',
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
                  controller: regCtrl,
                  label: 'Registration Number',
                  hintText: 'Enter registration number',
                  icon: Icons.numbers,
                  isFirst: true,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  context: context,
                  controller: nameCtrl,
                  label: 'Full Name',
                  hintText: 'Enter student full name',
                  icon: Icons.person,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  context: context,
                  controller: progCtrl,
                  label: 'Program',
                  hintText: 'Enter Program',
                  icon: Icons.school,
                ),
                const SizedBox(height: 15),
                _buildYearDropdown(context),

                const SizedBox(height: 24),
                _buildCheckbox(
                  title: 'Has RFID Card',
                  value: hasRfid,
                  onChanged: (val) {
                    setState(() => hasRfid = val);
                  },
                ),
                const SizedBox(height: 12),
                _buildCheckbox(
                  title: 'Has Fingerprint',
                  value: hasFingerprint,
                  onChanged: (val) {
                    setState(() => hasFingerprint = val);
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
                  onPressed: _save,
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
                        isEditing ? 'Update Student' : 'Add Student',
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
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool isFirst = false,
    String? errorText,
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
            border: Border.all(color: errorText != null ? Colors.red : Colors.grey.shade300),
            color: Colors.white,
          ),
          child: TextField(
            controller: controller,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  icon,
                  color: errorText != null ? Colors.red : Colors.grey.shade600,
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              errorText: errorText,
            ),
          ),
        ),
        if(errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildYearDropdown(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Year of Study',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedYear,
              isExpanded: true,
              items: List.generate(
                4,
                    (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text('Year ${index + 1}'),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selectedYear = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: (val) {
          if (val != null) {
            onChanged(val);
          }
        },
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500
          ),
        ),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

}