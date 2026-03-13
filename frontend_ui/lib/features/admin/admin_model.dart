import 'package:flutter/material.dart';

enum AdminRole {
  superAdmin,
  admin,
  manager,
  viewer,
}

extension AdminRoleExtension on AdminRole {
  String get displayName {
    switch (this) {
      case AdminRole.superAdmin:
        return 'Super Administrator';
      case AdminRole.admin:
        return 'Administrator';
      case AdminRole.manager:
        return 'Manager';
      case AdminRole.viewer:
        return 'viewer';
    }
  }

  String get description {
    switch (this) {
      case AdminRole.superAdmin:
        return 'Full system access, can manage other admins';
      case AdminRole.admin:
        return 'Can manage content and users';
      case AdminRole.manager:
        return 'Can view and manage specific sections';
      case AdminRole.viewer:
        return 'Read-only access';
    }
  }

  Color getColor(BuildContext context) {
    switch (this) {
      case AdminRole.superAdmin:
        return Colors.purple;
      case AdminRole.admin:
        return Colors.indigoAccent;
      case AdminRole.manager:
        return Colors.orangeAccent;
      case AdminRole.viewer:
        return Colors.teal;
    }
  }

  IconData get icon {
    switch (this) {
      case AdminRole.superAdmin:
        return Icons.admin_panel_settings;
      case AdminRole.admin:
        return Icons.security;
      case AdminRole.manager:
        return Icons.manage_accounts;
      case AdminRole.viewer:
        return Icons.visibility;
    }
  }
}

class AdminModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? department;
  final String? position;
  final AdminRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final String? profileImageUrl;
  final Map<String, dynamic>? permissions;

  AdminModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.department,
    this.position,
    required this.role,
    this.isActive = true,
    required this.createdAt,
    this.lastLogin,
    this.profileImageUrl,
    this.permissions,
});

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      department: json['department'],
      position: json['position'],
      role: _parseRole(json['role']),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      profileImageUrl: json['profileImageUrl'],
      permissions: json['permissions'],
    );
  }

  static AdminRole _parseRole(dynamic role) {
    if (role is String) {
      switch (role.toLowerCase()) {
        case 'superadmin':
        case 'super_admin':
        case 'super administrator':
          return AdminRole.superAdmin;
        case 'admin':
        case 'administrator':
          return AdminRole.admin;
        case 'manager':
          return AdminRole.manager;
        case 'viewer':
          return AdminRole.viewer;
      }
    } else if (role is int) {
      return AdminRole.values[role];
    }
    return AdminRole.viewer;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'department': department,
      'position': position,
      'role': role.index,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'profileImageUrl': profileImageUrl,
      'permissions': permissions,
    };
  }

  AdminModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? department,
    String? position,
    AdminRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLogin,
    String? profileImageUrl,
    Map<String, dynamic>? permissions,
}) {
    return AdminModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      position: position ?? this.position,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      permissions: permissions ?? this.permissions,
    );
  }
}