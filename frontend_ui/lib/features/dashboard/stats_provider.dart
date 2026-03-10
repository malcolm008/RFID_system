import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StatsProvider extends ChangeNotifier {
  int students = 0;
  int teachers = 0;
  int programs = 0;
  int courses = 0;
  int activeDevices = 0;

  Future<void> loadStats() async {
    final response = await http.get(
      Uri.parse("http://127.0.0.1:8000/attendance_api/stats/"),
    );

    final data = jsonDecode(response.body);

    if (data['status'] == 'success') {
      students = data['datat']['students'];
      teachers = data['data']['teachers'];
      programs = data['data']['programs'];
      courses = data['data']['courses'];
      activeDevices = data['data']['active_devices'];

      notifyListeners();
    }
  }
}