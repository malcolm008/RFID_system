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

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'].toString(),
      name: json['name'],
      regNumber: json['regNumner'],
      program: json['program'],
      year: int.parse(json['year'].toString()),
      hasRfid: json['hasRfid'] == 1 || json['hasRfid'] == true,
      hasFingerprint:
        json['hasFingerprint'] == 1 || json['hasFingerprint'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "regNumber": regNumber,
      "program": program,
      "year": year,
      "hasRfid": hasRfid,
      "hasFingerprint": hasFingerprint,
    };
  }
}