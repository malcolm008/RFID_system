// lib/features/notifications/notification_provider.dart

import 'package:flutter/material.dart';
import 'notification_service.dart';
import 'notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = notificationService;

  List<AppNotification> get notifications => _service.notifications;
  int get unreadCount => _service.unreadCount;

  void markAsRead(int id) {
    _service.markAsRead(id);
    notifyListeners();
  }

  void markAllAsRead() {
    _service.markAllAsRead();
    notifyListeners();
  }

  void clearAll() {
    _service.clearAll();
    notifyListeners();
  }

  void removeNotification(int id) {
    _service.removeNotification(id);
    notifyListeners();
  }

  // Add a test notification (for demonstration)
  void addTestNotification() {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Test Notification',
      body: 'This is a test notification',
      type: NotificationType.system,
      timestamp: DateTime.now(),
    );

    _service._addNotification(notification);
    notifyListeners();
  }
}