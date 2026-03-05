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

// In NotificationProvider
  void addEnrollmentNotification({
    required String type,
    required String name,
    String? details,
  }) {
    String title;
    String body;

    switch (type) {
      case 'student':
        title = '🎓 New Student Enrolled';
        body = '$name has been added to the system';
        break;
      case 'teacher':
        title = '👨‍🏫 New Teacher Added';
        body = '$name has joined as a new teacher';
        break;
      case 'program':
        title = '📚 New Program Created';
        body = '$name program has been added';
        break;
      case 'course':
        title = '📖 New Course Added';
        body = '$name course has been created';
        break;
      default:
        title = 'New Enrollment';
        body = '$name has been added';
    }

    if (details != null) {
      body = '$body\n$details';
    }

    // Add notification and get it back
    final notification = _service.addNotification(
      title: title,
      body: body,
      type: NotificationType.enrollment,
      data: {
        'enrollmentType': type,
        'name': name,
        'details': details,
      },
    );

    // IMPORTANT: Notify listeners that data has changed
    notifyListeners();

    debugPrint('✅ Notification added and UI notified');
  }

  void addEnrollmentDeleteNotification({
    required String type,
    required String name,
    String? details,
}) {
    String title;
    String body;

    switch (type) {
      case 'student':
        title = 'Student Removed';
        body = '$name has been removed from the system';
        break;

      case 'teacher':
        title = 'Teacher Removed';
        body = '$name has been removed from the system';
        break;

      case 'program':
        title = 'Program Removed';
        body = '$name program has been removed';
        break;

      case 'course':
        title = 'Course Deleted';
        body = '$name course has been deleted';
        break;

      default:
        title = 'Enrollment Removed';
        body = '$name has been removed';
    }

    if (details != null) {
      body = '$body\n$details';
    }
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

  void markAllAsRead() {
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