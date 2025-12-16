import 'package:flutter/material.dart';
import 'device_model.dart';

class DeviceFormScreen extends StatefulWidget {
  final Device? existingDevice;

  const DeviceFormScreen({
    super.key,
    this.existingDevice,
  });

  @override
  State<DeviceFormScreen> createState() => _DeviceFormScreenState();
}

class _DeviceFormScreenState extends State<DeviceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _assignedClassController = TextEditingController();

  DeviceType _deviceType = DeviceType.rfid;
  DeviceStatus _deviceStatus = DeviceStatus.offline;

  @override
  void initState() {
    super.initState();

    // Prefill fields if editing
    if (widget.existingDevice != null) {
      final d = widget.existingDevice!;
      _nameController.text = d.name;
      _locationController.text = d.location;
      _deviceType = d.type;
      _deviceStatus = d.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingDevice != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: Container(
        width: 550,
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
                      isEditing ? Icons.edit : Icons.devices_other,
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
                          isEditing ? 'Edit Device' : 'Register New Device',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isEditing
                              ? 'Update device configuration'
                              : 'Fill in the device details below',
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
              SingleChildScrollView(
                child: Column(
                  children: [
                    // Device Name
                    _buildTextField(
                      context: context,
                      controller: _nameController,
                      label: 'Device Name',
                      hintText: 'e.g. Main Gate Scanner',
                      icon: Icons.devices_other,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Device name is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Device Type
                    _buildDropdownField<DeviceType>(
                      context: context,
                      value: _deviceType,
                      label: 'Device Type',
                      hintText: 'Select device type',
                      icon: Icons.category,
                      items: DeviceType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: _getDeviceTypeColor(type).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  _getDeviceTypeIcon(type),
                                  size: 16,
                                  color: _getDeviceTypeColor(type),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(type.name.toUpperCase()),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _deviceType = value!),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select device type';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Location
                    _buildTextField(
                      context: context,
                      controller: _locationController,
                      label: 'Location',
                      hintText: 'Block A – Room 101',
                      icon: Icons.location_on,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Location is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Device Status
                    _buildDropdownField<DeviceStatus>(
                      context: context,
                      value: _deviceStatus,
                      label: 'Device Status',
                      hintText: 'Select device status',
                      icon: _deviceStatus == DeviceStatus.online
                          ? Icons.wifi
                          : Icons.wifi_off,
                      items: DeviceStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: status == DeviceStatus.online
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  status == DeviceStatus.online
                                      ? Icons.wifi
                                      : Icons.wifi_off,
                                  size: 16,
                                  color: status == DeviceStatus.online
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(status.name.toUpperCase()),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _deviceStatus = value!),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select device status';
                        }
                        return null;
                      },
                    ),

                    // Last Seen (read-only for editing)
                    if (isEditing) ...[
                      const SizedBox(height: 20),
                      _buildReadOnlyField(
                        context: context,
                        label: 'Last Seen',
                        value: widget.existingDevice!.lastSeen.toLocal().toString(),
                        icon: Icons.access_time,
                      ),
                    ],
                  ],
                ),
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
                    onPressed: _saveDevice,
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
                          isEditing ? 'Update Device' : 'Register Device',
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

  Widget _buildDropdownField<T>({
    required BuildContext context,
    required T? value,
    required String label,
    required String hintText,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
    required String? Function(T?)? validator,
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
          child: DropdownButtonFormField<T>(
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
            items: items,
            onChanged: onChanged,
            validator: (value) => validator?.call(value),
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

  Widget _buildReadOnlyField({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.grey.shade50,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getDeviceTypeColor(DeviceType type) {
    switch (type) {
      case DeviceType.fingerprint:
        return Colors.purple;
      case DeviceType.rfid:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getDeviceTypeIcon(DeviceType type) {
    switch (type) {
      case DeviceType.fingerprint:
        return Icons.fingerprint;
      case DeviceType.rfid:
        return Icons.credit_card;
      default:
        return Icons.devices_other;
    }
  }

  void _saveDevice() {
    if (_formKey.currentState!.validate()) {
      final device = Device(
        id: widget.existingDevice?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        type: _deviceType,
        location: _locationController.text.trim(),
        lastSeen: widget.existingDevice?.lastSeen ?? DateTime.now(),
        status: _deviceStatus,
      );

      // TODO: connect to provider / backend
      // deviceProvider.addOrUpdate(device);

      Navigator.pop(context, device);
    }
  }
}