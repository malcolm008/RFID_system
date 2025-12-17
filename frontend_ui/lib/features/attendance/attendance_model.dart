enum AttendanceStatus { present, late}

class AttendanceRecord {
  final String id;
  final String personName;
  final String role;
  final String program;
  final String course;
  final int year;
  final DateTime time;
  final AttendanceStatus status;
  final String device;

  AttendanceRecord({
    required this.id,
    required this.personName,
    required this.role,
    required this.program,
    required this.course,
    required this.year,
    required this.time,
    required this.status,
    required this.device,
  });
}