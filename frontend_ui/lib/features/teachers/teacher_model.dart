class Teacher {
  final String id;
  final String name;
  final String email;
  final String course;
  final String department;
  final bool hasRfid;
  final bool hasFingerprint;

  Teacher({
    required this.id,
    required this.name,
    required this.email,
    required this.course,
    required this.department,
    this.hasRfid = false,
    this.hasFingerprint = false,
  });
}
