enum AttendanceStatus { present, late}

class AttendanceRecord {
  final String id;
  final String personName;
  final String role;
  final String className;
  final DateTime time;
  final AttendanceStatus status;
  final String device;

  AttendanceRecord({
    required this.id,
    required this.personName,
    required this.role,
    required this.className,
    required this.time,
    required this.status,
    required this.device,
  });
}