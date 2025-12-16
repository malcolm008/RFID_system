class Student {
  final String id;
  final String name;
  final String regNumber;
  final String program;
  final int year;
  final bool hasRfid;
  final bool hasFingerprint;

  Student({
    required this.id,
    required this.name,
    required this.regNumber,
    required this.program,
    required this.year,
    this.hasRfid = false,
    this.hasFingerprint = false,
  });
}