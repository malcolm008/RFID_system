// lib/features/programs/timetable_model.dart

class TimetableEntry {
  final String id;
  final String programId;      // Add this
  final String program;        // Keep this for display name
  final String courseId;       // Add this
  final String course;         // Keep this for display name
  final String teacherId;      // Add this
  final String teacherName;    // Keep this for display name
  final String deviceId;       // Add this
  final String device;
  final String location;
  final int year;
  final String day;
  final String startTime;
  final String endTime;
  final String qualification;

  TimetableEntry({
    required this.id,
    required this.programId,      // Add
    required this.program,
    required this.courseId,       // Add
    required this.course,
    required this.teacherId,      // Add
    required this.teacherName,
    required this.deviceId,       // Add
    required this.device,
    required this.location,
    required this.year,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.qualification,
  });

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    return TimetableEntry(
      id: json['id'].toString(),

      // IDs from the response
      programId: json['program']?.toString() ?? '',  // The ID field from backend
      courseId: json['course']?.toString() ?? '',    // The ID field from backend
      teacherId: json['teacher']?.toString() ?? '',  // The ID field from backend
      deviceId: json['device']?.toString() ?? '',    // The ID field from backend (nullable)

      // Display names from the response
      program: json['program_name'] ?? json['program'].toString(),
      course: json['course_name'] ?? json['course'].toString(),
      teacherName: json['teacher_name'] ?? 'Unknwon Teacher',
      device: json['device_name'] ?? 'No device',

      // Other fields
      location: json['location'] ?? '',
      year: json['year'] ?? 1,
      day: json['day'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      qualification: json['qualification'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'program': programId,        // Send the ID, not the name
      'course': courseId,          // Send the ID, not the name
      'teacher': teacherId,        // Send the ID, not the name
      'device': deviceId.isEmpty ? null : deviceId,  // Send null if empty
      'location': location,
      'year': year,
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'qualification': qualification,
    };
  }
}