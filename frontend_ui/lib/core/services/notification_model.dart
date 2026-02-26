import 'package:flutter/material.dart';

enum NotificationType {
  Reminder,
  system,
  attendance,
  device,
  enrollment,
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final DateTime? scheduledTime;
  bool isRead;
  bool isShown;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.scheduledTime,
    this.isRead = false,
    this.isShown = false,
    this.data,
});

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? timestamp,
    DateTime? scheduledTime,
    bool? isRead,
    bool? isShown,
    Map<String, dynamic>? data,
}) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isRead: isRead ?? this.isRead,
      isShown: isShown ?? this.isShown,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.index,
      'timestamp': timestamp.toIso8601String(),
      'scheduledTime': scheduledTime?.toIso8601String(),
      'isRead': isRead,
      'isShown': isShown,
      'data': data,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: NotificationType.values[json['type']],
      timestamp: DateTime.parse(json['timestamp']),
      scheduledTime: json['scheduledTime'] != null ? DateTime.parse(json['scheduledTime']) : null,
      isRead: json['isRead'] ?? false,
      isShown: json['isShown'] ?? false,
      data: json['data'],
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  IconData get icon {
    switch (type) {
      case NotificationType.Reminder:
        return Icons.schedule;
      case NotificationType.system:
        return Icons.system_update;
      case NotificationType.attendance:
        return Icons.check_circle;
      case NotificationType.device:
        return Icons.device_hub;
      case NotificationType.enrollment:
        return Icons.person_add;
    }
  }

  Color getColor(BuildContext context) {
    switch (type) {
      case NotificationType.Reminder:
        return Colors.blue;
      case NotificationType.system:
        return Colors.purple;
      case NotificationType.attendance:
        return Colors.green;
      case NotificationType.device:
        return Colors.orange;
      case NotificationType.enrollment:
        return Colors.teal;
    }
  }
}