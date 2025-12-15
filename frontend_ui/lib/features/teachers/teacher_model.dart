class Teacher {
  final String id;
  final String name;
  final String email;
  final String subject;
  final String className;
  final bool hasRfid;
  final bool hasFingerprint;

  Teacher({
    required this.id,
    required this.name,
    required this.email,
    required this.subject,
    required this.className,
    this.hasRfid = false,
    this.hasFingerprint = false,
  });
}
