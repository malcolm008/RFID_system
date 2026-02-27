import 'package:flutter/material.dart';
import 'notification_model.dart';
import 'notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  List<NotificationModel> get notifications => _service.notifications;
  int get unreadCount => _service.unreadCount;
  bool get permissionGranted => _service.permissionGranted;
  bool get notificationsSupported => _service.notificationsSupported;

  Future<void> init() async {
    await _service.init();
    notifyListeners();
  }

  Future<bool> requestPermission() async {
    final result = await _service.requestPermission();
    notifyListeners();
    return result;
  }

  void scheduleReminder({
    required String courseName,
    required String teacherName,
    required DateTime startTime,
    required int reminderMinutes,
}) {
    _service.scheduleReminder(
      courseName: courseName,
      teacherName: teacherName,
      startTime: startTime,
      reminderMinutes: reminderMinutes,
    );
    notifyListeners();
  }

  void addSystemNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data
}) {
    _service.addSystemNotification(
      title: title,
      body: body,
      data: data,
    );
    notifyListeners();
  }

  void markAsRead(String id) {
    _service.markAsRead(id);
    notifyListeners();
  }

  void markAllAsRead(String id) {
    _service.markAllAsRead();
    notifyListeners();
  }

  void removeNotification(String id) {
    _service.removeNotification(id);
    notifyListeners();
  }

  void clearAll() {
    _service.clearAll();
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}