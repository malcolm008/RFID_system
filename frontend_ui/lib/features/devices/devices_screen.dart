import 'package:flutter/material.dart';
import 'package:frontend_ui/features/devices/device_form_screen.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/app_scaffold.dart';
import 'device_provider.dart';
import 'device_model.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  bool _isDeleteMode = false;
  Set<String> _selectedDeviceIds = {};

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<DeviceProvider>().loadDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeviceProvider>();
    final devices = provider.devices;
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
                      'Devices',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage attendance devices and their status',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Register Device'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => DeviceFormScreen(),
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
                    label: 'Total Devices',
                    value: '${devices.length}',
                    color: Colors.blue,
                    icon: Icons.devices_other,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    label: 'Online',
                    value: '${devices.where((d) => d.status == DeviceStatus.online).length}',
                    color: Colors.green,
                    icon: Icons.wifi,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    label: 'Offline',
                    value: '${devices.where((d) => d.status == DeviceStatus.offline).length}',
                    color: Colors.red,
                    icon: Icons.wifi_off,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_isDeleteMode)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: Text('Delete (${_selectedDeviceIds.length})'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: _selectedDeviceIds.isEmpty
                        ? null
                        : () async {
                      await context
                          .read<DeviceProvider>()
                          .bulkDeleteDevices(_selectedDeviceIds.toList());
                      setState(() {
                        _isDeleteMode = false;
                        _selectedDeviceIds.clear();
                      });
                    }
                  ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: Icon(_isDeleteMode ? Icons.close : Icons.delete_outline),
                  label: Text(_isDeleteMode ? 'Cancel' : 'Delete'),
                  onPressed: () {
                    setState(() {
                      _isDeleteMode = !_isDeleteMode;
                      _selectedDeviceIds.clear();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Devices Table
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
                      child: const Row(
                        children: [
                          Expanded(flex: 2, child: _TableHeader(text: 'Device')),
                          Expanded(child: _TableHeader(text: 'Type')),
                          Expanded(child: _TableHeader(text: 'Location')),
                          Expanded(child: _TableHeader(text: 'Status')),
                          Expanded(child: _TableHeader(text: 'Last Seen')),
                        ],
                      ),
                    ),

                    // Table Content
                    Expanded(
                      child: devices.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.devices_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No devices found',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Register your first device to get started',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      )
                          : SingleChildScrollView(
                        child: Column(
                          children: devices.map((d) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              decoration: BoxDecoration(
                                color: _selectedDeviceIds.contains(d.id)
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
                                        value: _selectedDeviceIds.contains(d.id),
                                        onChanged: (bool? value) {
                                          setState(() {
                                            if (value == true) {
                                              _selectedDeviceIds.add(d.id!);
                                            } else {
                                              _selectedDeviceIds.remove(d.id);
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: _getDeviceTypeColor(d.type).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            _getDeviceTypeIcon(d.type),
                                            color: _getDeviceTypeColor(d.type),
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                d.name,
                                                style: theme.textTheme.bodyLarge?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: isDarkMode ? Colors.white : Colors.grey.shade800,
                                                ),
                                              ),
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
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: _getDeviceTypeColor(d.type).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: _getDeviceTypeColor(d.type).withOpacity(0.3),
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    d.type.name.toUpperCase(),
                                                    style: theme.textTheme.bodySmall?.copyWith(
                                                      color: _getDeviceTypeColor(d.type),
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              )
                                          ),
                                        ],
                                      )
                                  ),
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: Colors.grey.shade500,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            d.location,
                                            style: theme.textTheme.bodyMedium,
                                            overflow: TextOverflow.ellipsis,
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
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: d.status == DeviceStatus.online
                                                ? Colors.green
                                                : Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          d.status == DeviceStatus.online ? 'Online' : 'Offline',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: d.status == DeviceStatus.online
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${DateTime.now().difference(d.lastSeen).inMinutes} min ago',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: isDarkMode ? Colors.white : Colors.grey.shade800,
                                          ),
                                        ),
                                      ],
                                    )
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