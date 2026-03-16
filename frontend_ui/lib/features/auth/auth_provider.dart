import 'package:flutter/material.dart';
import 'auth_model.dart';
import '../admin/admin_model.dart';

class AuthProvider extends ChangeNotifier {
  AuthUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null && _currentUser!.isAuthenticated;

  bool get canManageAdmins => _currentUser?.canManageAdmin ?? false;
  bool get canManageUsers => _currentUser?.canManageUsers ?? false;
  bool get canManageContent => _currentUser?.canManageContent ?? false;
  bool get isReadOnly => _currentUser?.isReadOnly ?? true;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      UserRole role;
      if (email.contains('super')) {
        role = UserRole.superAdmin;
      } else if (email.contains('admin')) {
        role = UserRole.admin;
      } else if (email.contains('manager')) {
        role = UserRole.manager;
      } else {
        role = UserRole.viewer;
      }

      _currentUser = AuthUser(
        id: '1',
        name: email.split('@')[0],
        email: email,
        role: role,
        token: 'dummy_token',
        isAuthenticated: true,
        lastLogin: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void loginWithAdmin(AdminModel admin, {String? token}) {
    _currentUser = AuthUser.fromAdmin(admin, token: token);
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  void updateUser(AuthUser user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  bool hasRole(UserRole role) {
    return _currentUser?.role == role;
  }

  bool hasAnyRole(List<UserRole> roles) {
    if (_currentUser == null) return false;
    return roles.contains(_currentUser!.role);
  }

  bool hasAllRoles(List<UserRole> roles) {
    if (_currentUser == null) return false;
    return roles.every((role) => _currentUser!.role == role);
  }
}

