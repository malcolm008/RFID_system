import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'admin_model.dart';
import '../../core/services/notification_provider.dart';

class AdminProvider extends ChangeNotifier {
  final String baseUrl = "http://127.0.0.1:8000/attendance_api/admin";
  final List<AdminModel> _admins = [];
  AdminModel? _currentAdmin;
  final NotificationProvider _notificationProvider;

  List<AdminModel> get admins => List.unmodifiable(_admins);
  AdminModel? get currentAdmin => currentAdmin;
  bool get isSuperAdmin => _currentAdmin?.role == AdminRole.superAdmin;

  AdminProvider({required NotificationProvider notificationProvider})
    : _notificationProvider = notificationProvider;

  Future<void> loadAdmins() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/list/"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if(jsonResponse["status"] == "success") {
          final List<dynamic> dataList = jsonResponse["data"];
          _admins.clear();
          _admins.addAll(
              dataList.map((json) => AdminModel.fromJson(json)).toList()
          );
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading admins: $e');
    }
  }

  Future<void> loadCurrentAdmin(String adminId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/$adminId/"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse["status"] == "success") {
          _currentAdmin = AdminModel.fromJson(jsonResponse["data"]);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading current admin: $e');
    }
  }

  Future<bool> addAdmin(AdminModel admin, String password) async {
    try {
      final Map<String, dynamic> adminData = {
        "name": admin.name,
        "email": admin.email,
        "password": password,
        "phone": admin.phone,
        "department": admin.department,
        "position": admin.position,
        "role": admin.role.index,
        "isActive": admin.isActive,
      };

      final response = await http.post(
        Uri.parse("$baseUrl/create/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(adminData),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if(response.statusCode == 201 && responseData["status"] == "success") {
        await loadAdmins();

        _notificationProvider.addEnrollmentNotification(
          type: 'admin',
          name: admin.name,
          details: 'Role: ${admin.role.displayName}',
        );

        return true;
      } else {
        throw Exception(responseData["message"] ?? "Failed to add admin");
      }
    } catch (e) {
      debugPrint('Error adding admin: $e');
      return false;
    }
  }

  Future<bool> updateAdmin(AdminModel admin) async {
    try {
      final Map<String, dynamic> adminData = {
        "id": admin.id,
        "name": admin.name,
        "email": admin.email,
        "phone": admin.phone,
        "department": admin.department,
        "position": admin.position,
        "role": admin.role.index,
        "isActive": admin.isActive,
      };

      final response = await http.post(
        Uri.parse("$baseUrl/update/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(adminData),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData["status"] == "success") {
        await loadAdmins();
        if (_currentAdmin?.id == admin.id) {
          _currentAdmin = admin;
        }
        return true;
      } else {
        throw Exception(responseData["message"] ?? "Failed to update admin");
      }
    } catch (e) {
      debugPrint('Error updating admin: $e');
      return false;
    }
  }

  Future<bool> deleteAdmin(String adminId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/delete/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": adminId}),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData["status"] == "success") {
        _admins.removeWhere((a) => a.id == adminId);
        notifyListeners();
        return true;
      } else {
        throw Exception(responseData["message"] ?? "Failed to delete admin");
      }
    } catch (e) {
      debugPrint('Error deleting admin: $e');
      return false;
    }
  }

  Future<bool> bulkDeleteAdmin(List<String> adminIds) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/bulk-delete/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"ids": adminIds}),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData["status"] == "success") {
        _admins.removeWhere((a) => adminIds.contains(a.id));

        notifyListeners();
        return true;
      } else {
        throw Exception(responseData["message"] ?? "Failed to delete admins");
      }
    } catch (e) {
      debugPrint('Error bulk deletinf admins: $e');
      return false;
    }
  }

  Future<bool> toggleAdminStatus(String adminId, bool isActive) async {
    try {
      final admin = _admins.firstWhere((a) => a.id == adminId);
      final updatedAdmin = admin.copyWith(isActive: isActive);

      return await updateAdmin(updatedAdmin);
    } catch (e) {
      debugPrint('Error toggling admin status: $e');
      return false;
    }
  }


  Future<bool> resetPassword(String adminId, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": adminId, "password": newPassword}),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return response.statusCode == 200 && responseData["status"] == "success";
    } catch (e) {
      debugPrint('Error resetting password: $e');
      return false;
    }
  }

  List<AdminModel> searchAdmins(String query) {
    if (query.isEmpty) return _admins;
    return _admins.where((admin) {
      return admin.name.toLowerCase().contains(query.toLowerCase()) || admin.email.toLowerCase().contains(query.toLowerCase()) || admin.role.displayName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<AdminModel> filterByRole(AdminRole? role) {
    if (role == null) return _admins;
    return _admins.where((admin) => admin.role == role).toList();
  }

  Map<AdminRole, int> getStats() {
    final stats = <AdminRole, int>{};
    for (var role in AdminRole.values) {
      stats[role] = _admins.where((a) => a.role == role).length;
    }
    return stats;
  }
}