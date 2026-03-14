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
              itemCount: filteredAdmins.length,
              itemBuilder: (context, index) {
                final admin = filteredAdmins[index];
                return _buildAdminCard(context, admin, provider);
              },
            ),
          ),
        ],
      )
    );
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

  Widget _buildAdminCard(
      BuildContext context,
      AdminModel admin,
      AdminProvider provider,
      ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: admin.isActive
              ? Colors.teal.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: admin.role.getColor(context).withOpacity(0.2),
          backgroundImage: admin.profileImageUrl != null
              ? NetworkImage(admin.profileImageUrl!)
              : null,
          child: admin.profileImageUrl == null
              ? Text(
            admin.name.isNotEmpty ? admin.name[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: admin.role.getColor(context),
            ),
          )
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                admin.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: admin.role.getColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: admin.role.getColor(context).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    admin.role.icon,
                    size: 14,
                    color: admin.role.getColor(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    admin.role.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: admin.role.getColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              admin.email,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            if (admin.department != null || admin.position != null) ...[
              const SizedBox(height: 2),
              Text(
                [
                  if (admin.position != null) admin.position,
                  if (admin.department != null) admin.department,
                ].join(' • '),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: admin.isActive ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  admin.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 12,
                    color: admin.isActive ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Created: ${_formatDate(admin.createdAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
                if (admin.lastLogin != null) ...[
                  const SizedBox(width: 12),
                  Text(
                    'Last login: ${_formatDate(admin.lastLogin!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) async {
            switch (value) {
              case 'edit':
                _showEditAdminDialog(context, admin);
                break;
              case 'reset_password':
                _showResetPasswordDialog(context, admin);
                break;
              case 'toggle_status':
                await provider.toggleAdminStatus(admin.id, !admin.isActive);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Admin ${admin.isActive ? 'deactivated' : 'activated'} successfully',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                break;
              case 'delete':
                _showDeleteConfirmation(context, admin, provider);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'reset_password',
              child: Row(
                children: [
                  Icon(Icons.lock_reset, size: 18),
                  SizedBox(width: 8),
                  Text('Reset Password'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle_status',
              child: Row(
                children: [
                  Icon(
                    admin.isActive ? Icons.block : Icons.check_circle,
                    size: 18,
                    color: admin.isActive ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(admin.isActive ? 'Deactivate' : 'Activate'),
                ],
              ),
            ),
            if (provider.isSuperAdmin && admin.id != provider.currentAdmin?.id)
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
          ],
        ),
        onTap: () => _showAdminDetails(context, admin),
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
          final provider = context.read<AdminProvider>();
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

  void _showDeleteConfirmation(
      BuildContext context,
      AdminModel admin,
      AdminProvider provider,
      ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Admin'),
          content: Text(
            'Are you sure you want to delete ${admin.name}? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await provider.deleteAdmin(admin.id);
                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${admin.name} deleted successfully'),
                      backgroundColor: Colors.teal,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showAdminDetails(BuildContext context, AdminModel admin) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: admin.role.getColor(context).withOpacity(0.2),
                    backgroundImage: admin.profileImageUrl != null
                        ? NetworkImage(admin.profileImageUrl!)
                        : null,
                    child: admin.profileImageUrl == null
                        ? Text(
                      admin.name.isNotEmpty ? admin.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: admin.role.getColor(context),
                      ),
                    )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          admin.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(admin.email),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Role', admin.role.displayName),
              _buildDetailRow('Status', admin.isActive ? 'Active' : 'Inactive'),
              if (admin.department != null)
                _buildDetailRow('Department', admin.department!),
              if (admin.position != null)
                _buildDetailRow('Position', admin.position!),
              if (admin.phone != null)
                _buildDetailRow('Phone', admin.phone!),
              _buildDetailRow('Created', _formatDate(admin.createdAt)),
              if (admin.lastLogin != null)
                _buildDetailRow('Last Login', _formatDate(admin.lastLogin!)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context, AdminModel admin) {
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Reset password for ${admin.name}'),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (passwordController.text != confirmController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Passwords do not match'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final provider = context.read<AdminProvider>();
                final success = await provider.resetPassword(
                  admin.id,
                  passwordController.text,
                );

                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
