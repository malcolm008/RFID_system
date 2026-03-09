import 'dart:async';
import 'dart:js' as js;
import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  bool _permissionGranted = false;
  bool get permissionGranted => _permissionGranted;

  bool _notificationsSupported = false;
  bool get notificationsSupported => _notificationsSupported;

  static const String _storageKey = 'notifications';

  Timer? _schedulerTimer;

  Future<void> init() async {
    await _loadNotifications();
    Timer.periodic(const Duration(seconds: 30), (_) {
      _checkDueNotifications();
    });
    _checkBrowserSupport();
    _startScheduler();
  }

  void _checkBrowserSupport() {
    try {
      _notificationsSupported = js.context.hasProperty('Notification') && html.Notification != null;

      if (_notificationsSupported) {
        _permissionGranted = html.Notification.permission == 'granted';
      }

      debugPrint('Browser notifications supported: $_notificationsSupported');
      debugPrint('Current permission: ${html.Notification.permission}');
    } catch (e) {
      _notificationsSupported = false;
      debugPrint('Error checking browser support: $e');
    }
  }

  Future<bool> requestPermission() async {
    try {
      if (js.context.hasProperty('Notification')) {
        final permission = await html.Notification.requestPermission();
        _permissionGranted = permission == 'granted';
        debugPrint('Browser notification permission: $permission');
        return _permissionGranted;
      } else {
        debugPrint('Browser does not support notifications');
        return false;
      }
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      return false;
    }
  }

  void _showBrowserNotifications(NotificationModel notification) {
    if (!_permissionGranted) return;

    try {
      if (html.Notification.permission == 'granted') {
        final browserNotification = html.Notification(
          notification.title,
          body: notification.body,
          tag: notification.id,
        );

        browserNotification.onClick.listen((event) {
          browserNotification.close();
        });

        Timer(const Duration(seconds: 10), () {
          browserNotification.close();
        });

        debugPrint('✅ Browser notification shown: ${notification.title}');
      }
    } catch(e) {
      debugPrint('❌ Error showing browser notification: $e');
    }
  }

  void scheduleReminder({
    required String courseName,
    required String teacherName,
    required DateTime startTime,
    required int reminderMinutes,
}) {
    final scheduledTime = startTime.subtract(Duration(minutes: reminderMinutes));

    if (scheduledTime.isBefore(DateTime.now())) return;

    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Upcoming Class',
      body: '$courseName with $teacherName starts in $reminderMinutes minutes',
      type: NotificationType.Reminder,
      timestamp: DateTime.now(),
      scheduledTime: scheduledTime,
      data: {
        'courseName': courseName,
        'teacherName': teacherName,
        'startTime': startTime.toIso8601String(),
        'reminderMinutes': reminderMinutes,
      },
    );
    _addNotification(notification);
  }

  void addSystemNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data
}) {
    final notification = NotificationModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: NotificationType.system,
      timestamp: DateTime.now(),
      data: data,
    );

    _addNotification(notification);
    _showBrowserNotifications(notification);
  }

  NotificationModel _addNotification(NotificationModel notification) {
    try {
      _notifications.insert(0, notification);
      _trimNotification();

      // Save asynchronously - don't await
      _saveNotifications().catchError((e) {
        debugPrint('Warning: Failed to save notification to storage: $e');
      });

      return notification; // Return the added notification
    } catch (e) {
      debugPrint('Error adding notification: $e');
      if (!_notifications.contains(notification)) {
        _notifications.insert(0, notification);
      }
      return notification;
    }
  }

  NotificationModel addNotification({
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      timestamp: DateTime.now(),
      data: data,
    );

    final addedNotification = _addNotification(notification);

    if (type == NotificationType.enrollment || type == NotificationType.device) {
      _showBrowserNotifications(addedNotification);
    }

    return addedNotification;
  }

  void _trimNotification() {
    if (_notifications.length > 50) {
      _notifications.removeRange(50, _notifications.length);
    }
  }

  void _startScheduler() {
    _schedulerTimer?.cancel();
    _schedulerTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkDueNotifications();
    });
  }

  void _checkDueNotifications() {
    final now = DateTime.now();
    bool updated = false;

    for (var i = 0; i < _notifications.length; i++) {
      final notification = _notifications[i];

      if (!notification.isShown && notification.scheduledTime != null && now.isAfter(notification.scheduledTime!)){
        _showBrowserNotifications(notification);
        _notifications[i] = notification.copyWith(isShown: true);
        updated = true;
      }
    }

    if (updated) {
      _saveNotifications();
    }
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _saveNotifications();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _saveNotifications();
  }

  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    _saveNotifications();
  }

  void clearAll() {
    _notifications.clear();
    _saveNotifications();
  }

  int get unreadCount {
    return _notifications.where((n) => !n.isRead).length;
  }

  Future<void> _saveNotifications() async {
    try {
      debugPrint('=' * 50);
      debugPrint('Saving ${_notifications.length} notifications');

      final List<Map<String, dynamic>> jsonList = [];

      for (var i = 0; i < _notifications.length; i++) {
        final notification = _notifications[i];
        debugPrint('Notification $i:');
        debugPrint('  id: ${notification.id}');
        debugPrint('  title: ${notification.title}');
        debugPrint('  body: ${notification.body}');
        debugPrint('  type: ${notification.type}');
        debugPrint('  timestamp: ${notification.timestamp}');
        debugPrint('  scheduledTime: ${notification.scheduledTime}');
        debugPrint('  isRead: ${notification.isRead}');
        debugPrint('  isShown: ${notification.isShown}');
        debugPrint('  data: ${notification.data}');

        try {
          final json = notification.toJson();
          debugPrint('  toJson result: $json');
          jsonList.add(json);
        } catch (e) {
          debugPrint('  ERROR converting notification $i: $e');
        }
      }

      debugPrint('JSON List length: ${jsonList.length}');
      final String encoded = jsonEncode(jsonList);
      debugPrint('Encoded JSON: $encoded');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, encoded);
      debugPrint('Notifications saved successfully');
      debugPrint('=' * 50);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encoded = prefs.getString(_storageKey);

      if (encoded != null) {
        final List<dynamic> jsonList = jsonDecode(encoded);
        _notifications.clear();
        _notifications.addAll(
          jsonList.map((json) => NotificationModel.fromJson(json)).toList()
        );
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  Future<void> clearCorruptedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      _notifications.clear();
      debugPrint('Cleared corrupted notification data');
    } catch (e) {
      debugPrint('Error clearing data: $e');
    }
  }

  void dispose() {
    _schedulerTimer?.cancel();
  }
}