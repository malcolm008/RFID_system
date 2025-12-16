class TimetableEntry {
  final String id;
  final String program;
  final String course;
  final String teacherName;
  final String location;
  final String device;
  final int year;
  final String day;
  final String startTime;
  final String endTime;

  TimetableEntry({
    required this.id,
    required this.program,
    required this.course,
    required this.teacherName,
    required this.location,
    required this.device,
    required this.year,
    required this.day,
    required this.startTime,
    required this.endTime,
  });
}