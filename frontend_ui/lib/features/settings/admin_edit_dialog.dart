import 'package:flutter/material.dart';
export 'package:image_picker/image_picker.dart';
import 'dart:io';

class AdminEditDialog extends StatefulWidget {
  final Map<String, dynamic> adminData;

  const AdminEditDialog({
    super.key,
    required this.adminData;
});

  @override
  State<AdminEditDialog> createState() => _AdminEditDialogState();
}

class _AdminEditDialogState extends State<AdminEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _departmentController;
  late TextEditingController _positionController;
  late TextEditingController _bioController;

  String? _selectedRole;
  bool _isActive = true;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> _roles = [
    'Super Administrator',
    'Administrator',
    'Manager',
    'Viewer',
  ];

  @override
  void initState() {
    super.initState();
    initializeControllers();
  }

  void initializeControllers() {
    _nameController = TextEditingController(text: widget.adminData['name'] ?? 'John Doe');
    _emailController = TextEditingController(text: widget.adminData['email'] ?? 'admin@example.com');
    _phoneController = TextEditingController(text: widget.adminData['phone'] ?? '+1 234 567 890');
    _departmentController = TextEditingController(text: widget.adminData['department'] ?? 'Administration');
    _positionController = TextEditingController(text: widget.adminData['position'] ?? 'System Administrator');
    _bioController = TextEditingController(text: widget.adminData['bio'] ?? 'Experienced administrator with a background in computer science.');
    _selectedRole = widget.adminData['role'] ?? _roles[0];
    _isActive = widget.adminData['isActive'] ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _positionController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 8,
      child: Container(
        width: 600,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Administrator',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Update administrator details and permissions',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const Edge
              )
            )
          ],
        )
      )
    )
  }
}