class TimetableEntry {
  final String id;
  final String className;
  final String subjectName;
  final String teacherName;
  final String day;
  final String startTime;
  final String endTime;

  TimetableEntry({
    required this.id,
    required this.className,
    required this.subjectName,
    required this.teacherName,
    required this.day,
    required this.startTime,
    required this.endTime,
  });
}