import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'admin_model.dart';
import '../../core/services/notification_provider.dart';

class AdminProvider extends ChangeNotifier {
  final String baseUrl = "http://127.0.0.1:8000/attendance_api/admin";
  final List<AdminRole> _admins = [];
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


}