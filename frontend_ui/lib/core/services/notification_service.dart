// lib/core/services/notification_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  final List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  // Initialize notifications
  Future<void> init() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Android settings
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response);
      },
      onDidReceiveBackgroundNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response);
      },
    );

    // Request permissions
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Android permissions are granted at install time
    // iOS requires permission request
    await _notificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _handleNotificationTap(NotificationResponse response) {
    // Handle notification tap - navigate to relevant screen
    debugPrint('Notification tapped: ${response.payload}');
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
      title: 'Upcoming Class',
      body: '$courseName with $teacherName starts in $reminderMinutes minutes',
      type: NotificationType.Reminder,
      timestamp: DateTime.now(),
      relatedData: {
        'courseName': courseName,
        'teacherName': teacherName,
        'startTime': startTime.toIso8601String(),
        'reminderMinutes': reminderMinutes,
      },
    );

    // Add to in-app notification list
    _addNotification(notification);

    // Schedule local notification
    await _notificationsPlugin.zonedSchedule(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'class_reminders',
          'Class Reminders',
          channelDescription: 'Notifications for upcoming classes',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'schedule',
        ),
        iOS: DarwinNotificationDetails(
          categoryIdentifier: 'class_reminder',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exact,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Add notification to in-app list
  void _addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    // Keep only last 50 notifications
    if (_notifications.length > 50) {
      _notifications.removeLast();
    }
  }

  // Mark notification as read
  void markAsRead(int id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  // Mark all as read
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  // Clear all notifications
  void clearAll() {
    _notifications.clear();
    _notificationsPlugin.cancelAll();
  }

  // Remove a specific notification
  void removeNotification(int id) {
    _notifications.removeWhere((n) => n.id == id);
    _notificationsPlugin.cancel(id);
  }

  // Get unread count
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
}

// Singleton instance
final notificationService = NotificationService();