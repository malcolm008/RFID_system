import 'package:flutter/material.dart';

enum NotificationType {
  Reminder,
  system,
  attendance,
  device,
  enrollment
}

class AppNotification {
  final int id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? relatedData;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.relatedData,
});

  AppNotification copyWith({
    int? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? relatedData,
}) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      relatedData: relatedData ?? this.relatedData,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
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
        return Colors.pinkAccent;
      case NotificationType.system:
        return Colors.purpleAccent;
      case NotificationType.attendance:
        return Colors.teal;
      case NotificationType.device:
        return Colors.orange.shade200;
      case NotificationType.enrollment:
        return Colors.tealAccent;
    }
  }
}