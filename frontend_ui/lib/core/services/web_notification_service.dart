// lib/core/services/web_notification_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_web_notification_platform/flutter_web_notification_platform.dart';
import 'notification_model.dart';
import 'dart:html' as html;

class WebNotificationService {
  static final WebNotificationService _instance = WebNotificationService._internal();
  factory WebNotificationService() => _instance;
  WebNotificationService._internal();

  final FlutterWebNotificationPlatform _notificationPlatform =
  FlutterWebNotificationPlatform();

  final List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  bool _permissionGranted = false;
  bool get permissionGranted => _permissionGranted;

  // Callback for notification clicks
  Function(AppNotification)? onNotificationClick;

  // Initialize web notifications
  Future<void> init() async {
    _loadFromLocalStorage();
    _startNotificationScheduler();
  }

  // Request notification permission
  Future<bool> requestPermission() async {
    try {
      _permissionGranted = await _notificationPlatform.requestPermission();
      return _permissionGranted;
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      return false;
    }
  }

  // Show a web notification
  void _showWebNotification({
    required String title,
    required String body,
    required int id,
    String? tag,
  }) {
    if (!_permissionGranted) return;

    try {
      _notificationPlatform.showNotification(
        title: title,
        body: body,
      );

      // Note: The package doesn't support click handlers directly
      // You'll need to handle navigation separately
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  // Schedule a class reminder notification
  Future<void> scheduleClassReminder({
    required String courseName,
    required String teacherName,
    required DateTime startTime,
    required int reminderMinutes,
  }) async {
    final scheduledTime = startTime.subtract(Duration(minutes: reminderMinutes));

    // Don't schedule if the time is in the past
    if (scheduledTime.isBefore(DateTime.now())) return;

    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🔔 Upcoming Class',
      body: '$courseName with $teacherName starts in $reminderMinutes minutes',
      type: NotificationType.classReminder,
      timestamp: DateTime.now(),
      scheduledTime: scheduledTime,
      relatedData: {
        'courseName': courseName,
        'teacherName': teacherName,
        'startTime': startTime.toIso8601String(),
        'reminderMinutes': reminderMinutes,
      },
    );

    // Add to in-app notification list
    _addNotification(notification);
  }

  // Schedule a test notification
  void scheduleTestNotification() {
    final now = DateTime.now();
    final testNotification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🧪 Test Notification',
      body: 'This is a test notification from your system',
      type: NotificationType.system,
      timestamp: now,
      scheduledTime: now.add(const Duration(seconds: 5)),
      relatedData: {},
    );

    _addNotification(testNotification);
  }

  // Start the notification scheduler
  void _startNotificationScheduler() {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkScheduledNotifications();
    });
  }

  // Check for due notifications
  void _checkScheduledNotifications() {
    final now = DateTime.now();

    for (var notification in _notifications) {
      if (!notification.isShown &&
          notification.scheduledTime != null &&
          notification.scheduledTime!.isBefore(now)) {

        _showWebNotification(
          title: notification.title,
          body: notification.body,
          id: notification.id,
          tag: '${notification.type}_${notification.id}',
        );

        // Mark as shown
        final index = _notifications.indexOf(notification);
        _notifications[index] = notification.copyWith(isShown: true);
        _saveToLocalStorage();
      }
    }
  }

  // Add notification to in-app list
  void _addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    // Keep only last 50 notifications
    if (_notifications.length > 50) {
      _notifications.removeLast();
    }
    _saveToLocalStorage();
  }

  // Save to localStorage
  void _saveToLocalStorage() {
    try {
      final storage = html.window.localStorage;
      final notificationsJson = _notifications.map((n) => n.toJson()).toList();
      storage['notifications'] = js.context['JSON'].callMethod('stringify', [notificationsJson]);
    } catch (e) {
      debugPrint('Error saving to localStorage: $e');
    }
  }

  // Load from localStorage
  void _loadFromLocalStorage() {
    try {
      final storage = html.window.localStorage;
      final notificationsJson = storage['notifications'];

      if (notificationsJson != null && notificationsJson.isNotEmpty) {
        final List<dynamic> notificationsList = js.context['JSON'].callMethod('parse', [notificationsJson]);

        _notifications.clear();
        for (var json in notificationsList) {
          _notifications.add(AppNotification.fromJson(json));
        }
        _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
    } catch (e) {
      debugPrint('Error loading from localStorage: $e');
    }
  }

  // Mark notification as read
  void markAsRead(int id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _saveToLocalStorage();
    }
  }

  // Mark all as read
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _saveToLocalStorage();
  }

  // Clear all notifications
  void clearAll() {
    _notifications.clear();
    try {
      html.window.localStorage.remove('notifications');
    } catch (e) {
      debugPrint('Error clearing localStorage: $e');
    }
  }

  // Remove a specific notification
  void removeNotification(int id) {
    _notifications.removeWhere((n) => n.id == id);
    _saveToLocalStorage();
  }

  // Get unread count
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
}

// Singleton instance
final webNotificationService = WebNotificationService();
