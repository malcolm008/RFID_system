import 'package:flutter/material.dart';
import '../admin/admin_model.dart';

enum UserRole {
  superAdmin,
  admin,
  manager,
  viewer,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Administrator';
      case UserRole.admin:
        return 'Administrator';
      case UserRole.manager:
        return 'Manager';
      case UserRole.viewer:
        return 'Viewer';
    }
  }

  String get description {
    switch (this) {
      case UserRole.superAdmin:
        return 'Full system access, can manage other admins';
      case UserRole.admin:
        return 'Can manage content and users';
      case UserRole.manager:
        return 'Can view and manage specific sections';
      case UserRole.viewer:
        return 'Read-only access';
    }
  }

  Color getColor(BuildContext context) {
    switch (this) {
      case UserRole.superAdmin:
        return Colors.purple;
      case UserRole.admin:
        return Colors.indigoAccent;
      case UserRole.manager:
        return Colors.deepOrangeAccent;
      case UserRole.viewer:
        return Colors.teal;
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.superAdmin:
        return Icons.admin_panel_settings;
      case UserRole.admin:
        return Icons.security;
      case UserRole.manager:
        return Icons.manage_accounts;
      case UserRole.viewer:
        return Icons.visibility;
    }
  }

  static UserRole fromAdminRole(AdminRole role) {
    switch (role) {
      case AdminRole.superAdmin:
        return UserRole.superAdmin;
      case AdminRole.admin:
        return UserRole.admin;
      case AdminRole.manager:
        return UserRole.manager;
      case AdminRole.viewer:
        return UserRole.viewer;
    }
  }

  AdminRole toAdminRole() {
    switch (this) {
      case UserRole.superAdmin:
        return AdminRole.superAdmin;
      case UserRole.admin:
        return AdminRole.admin;
      case UserRole.manager:
        return AdminRole.manager;
      case UserRole.viewer:
        return AdminRole.viewer;
    }
  }
}

class AuthUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? token;
  final bool isAuthenticated;
  final DateTime? lastLogin;

  AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.token,
    this.isAuthenticated = false,
    this.lastLogin,
});

  factory AuthUser.fromAdmin(AdminModel admin, {String? token}) {
    return AuthUser(
      id: admin.id,
      name: admin.name,
      email: admin.email,
      role: UserRoleExtension.fromAdminRole(admin.role),
      token: token,
      isAuthenticated: true,
      lastLogin: admin.lastLogin ?? DateTime.now(),
    );
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: _parseRole(json['role']),
      token: json['token'],
      isAuthenticated: json['isAuthenticated'] ?? false,
      lastLogin: json['lastLogin'] != null
        ? DateTime.parse(json['lastLogin'])
          : null,
    );
  }

  static UserRole _parseRole(dynamic role) {
    if (role is String) {
      switch (role.toLowerCase()) {
        case 'superadmin':
        case 'super_admin':
        case 'super administrators':
          return UserRole.superAdmin;
        case 'admin':
        case 'administrators':
          return UserRole.admin;
        case 'manager':
          return UserRole.manager;
        case 'viewer':
          return UserRole.viewer;
      }
    } else if (role is int) {
      return UserRole.values[role];
    }
    return UserRole.viewer;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.index,
      'token': token,
      'isAuthenticated': isAuthenticated,
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  bool get canManageAdmin => role == UserRole.superAdmin;

  bool get canManageUsers => role == UserRole.superAdmin || role == UserRole.admin;

  bool get canManageContent => role != UserRole.viewer;

  bool get isReadOnly => role == UserRole.viewer;

  AuthUser copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? token,
    bool? isAuthenticated,
    DateTime? lastLogin,
}) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      token: token ?? this.token,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class LoginResponse {
  final bool success;
  final String? message;
  final AuthUser? user;
  final String? token;

  LoginResponse({
    required this.success,
    this.message,
    this.user,
    this.token,
});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'],
      user: json['user'] != null ? AuthUser.fromJson(json['user']) : null,
      token: json['token'],
    );
  }
}