import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin_provider.dart';
import 'admin_model.dart';
import 'admin_form_dialog.dart';
import '../../core/widgets/app_scaffold.dart';

class AdminManagementScreen extends StatefulWidget{
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  String _searchQuery = '';
  AdminRole? _selectedRoleFilter;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  Future<void> _loadAdmins() async {
    final provider = context.read<AdminProvider>();
    await provider.loadAdmins();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<AdminProvider>();

    final filteredAdmins = provider.admins.where((admin) {
      if (_selectedRoleFilter != null && admin.role != _selectedRoleFilter) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        return admin.name.toLowerCase().contains(_searchQuery.toLowerCase()) || admin.email.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();

    final stats = provider.getStats();

    return AppScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Management',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage system administratos and their permissions',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                if (provider.isSuperAdmin)
                  ElevatedButton.icon(
                    onPressed: () => _showAddAdminDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Admin'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _buildStatCard(
                  context,
                  title: 'Total Admins',
                  value: provider.admins.length.toString(),
                  icon: Icons.admin_panel_settings,
                  color: Colors.indigoAccent,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  context,
                  title: 'Super Admins',
                  value: stats[AdminRole.superAdmin].toString(),
                  icon: Icons.star,
                  color: Colors.purple
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  context,
                  title: 'Active Now',
                  value: provider.admins.where((a) => a.isActive).length.toString(),
                  icon: Icons.circle,
                  color: Colors.teal,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search admins...',
                        prefixIcon: const Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Container(
                  width: 180,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<AdminRole?>(
                      value: _selectedRoleFilter,
                      hint: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('All Roles'),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('All Roles'),
                          ),
                        ),
                        ...AdminRole.values.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Icon(
                                    role.icon,
                                    size: 18,
                                    color: role.getColor(context),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(role.displayName),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRoleFilter = value;
                        });
                      },
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                if (_searchQuery.isNotEmpty || _selectedRoleFilter != null)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedRoleFilter = null;
                        _searchController.clear();
                      });
                    },
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear filters',
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: filteredAdmins.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),

            )
          )
        ],
      )
    )
  }
  
  Widget _buildStatCard(
      BuildContext context, {
        required String title,
        required String value,
        required IconData icon,
        required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.admin_panel_settings_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No admins found',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedRoleFilter != null
                ? 'Try adjusting your filters'
                : 'Click "Add Admin" tp create your first admin',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAdminDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AdminFormDialog(
        onSave: (admin, password) async {
          final provider = context.read(AdminProvider());
          final success = await provider.addAdmin(admin, password);
          if (success && context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Admin added successfully'),
                backgroundColor: Colors.teal,
              ),
            );
          }
        },
      ),
    );
  }

  void _showEditAdminDialog(BuildContext context, AdminModel admin) {
    showDialog(
      context: context,
      builder: (context) => AdminFormDialog(
        admin: admin,
        onSave: (updatedAdmin, _) async {
          final provider = context.read<AdminProvider>();
          final success = await provider.updateAdmin(updatedAdmin);
          if (success && context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Admin updated successfully'),
                backgroundColor: Colors.teal,
              ),
            );
          }
        },
      ),
    );
  }
}
