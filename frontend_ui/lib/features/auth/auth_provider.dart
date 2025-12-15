import 'package:flutter/material.dart';
import 'auth_model.dart';

class AuthProvider extends ChangeNotifier {
  AuthUser? _user;

  AuthUser? get user => _user;
  bool get isAuthenticated => _user != null;

  Future<void> login(String email, String password) async {
    //MOCK AUTH (replace with API later)
    await Future.delayed(const Duration(seconds: 1));

    if (email.contains('admin')) {
      _user = AuthUser(
        id: '1',
        name: 'Admin User',
        role: UserRole.admin,
      );
    } else {
      _user = AuthUser(
        id: '2',
        name: 'Teacher User',
        role: UserRole.teacher,
      );
    }
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}