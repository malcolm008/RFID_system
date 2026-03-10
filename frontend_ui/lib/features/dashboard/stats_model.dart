class DashboardStats {
  final int students;
  final int teachers;
  final int programs;
  final int courses;
  final int activeDevices;

  DashboardStats({
    required this.students,
    required this.teachers,
    required this.programs,
    required this.courses,
    required this.activeDevices,
});

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      students: json['students'],
      teachers: json['teachers'],
      programs: json['programs'],
      courses: json['courses'],
      activeDevices: json['active_devices'],
    );
  }
}