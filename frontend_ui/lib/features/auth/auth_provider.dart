import 'package:flutter/material.dart';
import 'auth_model.dart';
import '../admin/admin_model.dart';
import 'auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

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
      final result = await _authService.login(email, password);
      print('Login result: $result');

      if (result['success']) {
        final userData = result['user'];
        print('User data received: $userData');

        UserRole role;
        final roleValue = userData['role'];
        if (roleValue is int) {
          switch (roleValue) {
            case 0: role = UserRole.superAdmin; break;
            case 1: role = UserRole.admin; break;
            case 2: role = UserRole.manager; break;
            default: role = UserRole.viewer;
          }
        } else {
          role = UserRole.viewer;
        }

        _currentUser = AuthUser(
          id: userData['id'].toString(),
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          role: role,
          token: result['sessionId'], // Use session ID as token
          isAuthenticated: true,
          lastLogin: userData['lastLogin'] != null
              ? DateTime.parse(userData['lastLogin'])
              : DateTime.now(),
        );

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Login exception: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  UserRole _parseRole(dynamic role) {
    if (role is int) {
      switch (role) {
        case 0: return UserRole.superAdmin;
        case 1: return UserRole.admin;
        case 2: return UserRole.manager;
        case 3: return UserRole.viewer;
        default: return UserRole.viewer;
      }
    }
    return UserRole.viewer;
  }

  void loginWithAdmin(AdminModel admin, {String? token}) {
    _currentUser = AuthUser.fromAdmin(admin, token: token);
    notifyListeners();
  }

  Future<void> refreshUser() async {
    if (_currentUser == null) return ;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.getCurrentUser();

      if (result['success']) {
        final userData = result['user'];

        UserRole role;
        final roleValue = userData['role'];
        if (roleValue is int) {
          switch (roleValue) {
            case 0: role = UserRole.superAdmin; break;
            case 1: role = UserRole.admin; break;
            case 2: role = UserRole.manager; break;
            default: role = UserRole.viewer;
          }
        } else {
          role = UserRole.viewer;
        }

        _currentUser = AuthUser(
          id: userData['id'].toString(),
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          role: _parseRole(userData['role']),
          token: _currentUser?.token,
          isAuthenticated: true,
          lastLogin: userData['lastLogin'] != null
              ? DateTime.parse(userData['lastLogin'])
              : _currentUser?.lastLogin,
        );
      } else {
        _currentUser = null;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Refresh user error: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  void updateUser(AuthUser user) {
    _currentUser = user;
    notifyListeners();
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

  Future<bool> checkAuthStatus() async {
    if (_isLoading) return false;

    _isLoading = true;

    try {
      final result = await _authService.getCurrentUser();

      if (result['success']) {
        final userData = result['user'];

        UserRole role;
        final roleValue = userData['role'];
        if (roleValue is int) {
          switch (roleValue) {
            case 0: role = UserRole.superAdmin; break;
            case 1: role = UserRole.admin; break;
            case 2: role = UserRole.manager; break;
            default: role = UserRole.viewer;
          }
        } else {
          role = UserRole.viewer;
        }

        _currentUser = AuthUser(
          id: userData['id'].toString(),
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          role: role,
          isAuthenticated: true,
          lastLogin: userData['lastLogin'] != null
              ? DateTime.tryParse(userData['lastLogin'])
              : DateTime.now(),
        );

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('Check auth status error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }
}

