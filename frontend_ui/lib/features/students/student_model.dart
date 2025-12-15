class Student {
  final String id;
  final String name;
  final String regNumber;
  final String className;
  final bool hasRfid;
  final bool hasFingerprint;

  Student({
    required this.id,
    required this.name,
    required this.regNumber,
    required this.className,
    this.hasRfid = false,
    this.hasFingerprint = false,
  });
}