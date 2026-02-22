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
  final String qualification;

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
    required this.qualification,
  });

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    return TimetableEntry(
      id: json['id'].toString(),
      program: json['program_name'] ?? json['program'].toString(),
      course: json['course_name'] ?? json['course'].toString(),
      teacherName: json['teacher_name'] ?? json['teacher'].toString(),
      location: json['location'] ?? '',
      device: json['device_name'] ?? '',
      year: json['year'] ?? 1,
      day: json['day'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      qualification: json['qualification'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'program': program,           // In create/update, we'll send IDs, not names.
      'course': course,             // This will be replaced by ID mapping in the API service.
      'teacher': teacherName,
      'device': device,
      'location': location,
      'year': year,
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'qualification': qualification,
    };
  }
}