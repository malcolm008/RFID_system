import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'teacher_model.dart';
import 'teacher_provider.dart';

class TeacherFormDialog extends StatefulWidget {
  final Teacher? teacher;
  const TeacherFormDialog({super.key, this.teacher});

  @override
  State<TeacherFormDialog> createState() => _TeacherFormDialogState();
}

class _TeacherFormDialogState extends State<TeacherFormDialog> {
  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController courseCtrl;
  late TextEditingController depCtrl;
  late bool hasRfid;
  late bool hasFingerprint;

  @override
  void initState() {
    nameCtrl = TextEditingController(text: widget.teacher?.name);
    emailCtrl = TextEditingController(text: widget.teacher?.email);
    courseCtrl = TextEditingController(text: widget.teacher?.course);
    depCtrl = TextEditingController(text: widget.teacher?.department);
    hasRfid = widget.teacher?.hasRfid ?? false;
    hasFingerprint = widget.teacher?.hasFingerprint ?? false;
    super.initState();
  }

  void _save() async {
    final provider = context.read<TeacherProvider>();

    if (nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter teacher name")),
      );
      return;
    }

    if (emailCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter teacher's email")),
      );
      return;
    }

    if (courseCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter teacher's course")),
      );
      return;
    }

    if (depCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter teacher's department")),
      );
      return;
    }

    try {
      final teacher = Teacher(
        id: widget.teacher?.id ?? '',
        name: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        course: courseCtrl.text.trim(),
        department: depCtrl.text.trim(),
        hasRfid: hasRfid,
        hasFingerprint: hasFingerprint,
      );

      if (widget.teacher == null) {
        await provider.addTeacher(teacher);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Teacher added successfully"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await provider.updateTeacher(teacher);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Teacher updated successfully"),
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
      print("Error saving teacher: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.teacher != null;

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
                        isEditing ? 'Edit Teacher' : 'Add New Teacher',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isEditing
                            ? 'Update teacher information'
                            : 'Fill in the teacher details below',
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
                  controller: nameCtrl,
                  label: 'Full Name',
                  hintText: 'Enter teacher full name',
                  icon: Icons.person,
                  isFirst: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  context: context,
                  controller: emailCtrl,
                  label: 'Email Address',
                  hintText: 'Enter teacher email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  context: context,
                  controller: courseCtrl,
                  label: 'Course',
                  hintText: 'Enter teaching course',
                  icon: Icons.subject,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  context: context,
                  controller: depCtrl,
                  label: 'Department',
                  hintText: 'Enter assigned department',
                  icon: Icons.school,
                ),
                const SizedBox(height: 20),
                _buildCheckbox(
                  title: 'Has RFID Card',
                  value: hasRfid,
                  onChanged: (val) {
                    setState(() => hasRfid = val);
                  },
                ),
                const SizedBox(height: 20),
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
                        isEditing ? 'Update Teacher' : 'Add Teacher',
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
    TextInputType keyboardType = TextInputType.text,
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
            keyboardType: keyboardType,
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