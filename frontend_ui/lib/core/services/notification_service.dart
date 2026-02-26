import 'dart:async';
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
    _checkBrowserSupport();
    _startScheduler();
  }

  void _checkBrowserSupport() {
    try {
      _notificationsSupported = true;
    } catch (e) {
      _notificationsSupported = false;
    }
  }

  Future<bool> requestPermission() async {
    try {
      _permissionGranted = true;
      return true;
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      return false;
    }
  }

  void _showBrowserNotifications(NotificationModel notification) {
    if (!_permissionGranted) return;

    try {
      debugPrint('🔔 NOTIFICATION: ${notification.title} - ${notification.body}');
    } catch (e) {
      debugPrint('Error showing notifications: $e');
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
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: NotificationType.system,
      timestamp: DateTime.now(),
      data: data,
    );

    _addNotification(notification);
  }

  void _addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    _trimNotification();
    _saveNotifications();
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

      if (!notification.isShown && notification.scheduledTime != null && notification.scheduledTime!.isBefore(now)){
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
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = _notifications.map((n) => n.toJson()).toList();
      final String encoded = jsonEncode(jsonList);
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
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

  void dispose() {
    _schedulerTimer?.cancel();
  }
}