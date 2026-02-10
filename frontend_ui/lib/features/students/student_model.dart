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
    print("Parsing JSON: $json");

    return Student(
      id: json['id']?.toString() ?? '0', // Handle null id for new students
      name: json['name']?.toString() ?? '',
      regNumber: json['regNumber']?.toString() ?? '',
      program: json['program']?.toString() ?? '',
      year: int.tryParse(json['year']?.toString() ?? '1') ?? 1,
      hasRfid: json['hasRfid'] == 1 || json['hasRfid'] == true,
      hasFingerprint: json['hasFingerprint'] == 1 || json['hasFingerprint'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id.isNotEmpty ? int.tryParse(id) ?? 0 : 0,
      "name": name,
      "regNumber": regNumber,
      "program": program,
      "year": year,
      "hasRfid": hasRfid ? 1 : 0,
      "hasFingerprint": hasFingerprint ? 1 : 0,
    };
  }

  // Create a copy with updated values
  Student copyWith({
    String? id,
    String? name,
    String? regNumber,
    String? program,
    int? year,
    bool? hasRfid,
    bool? hasFingerprint,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      regNumber: regNumber ?? this.regNumber,
      program: program ?? this.program,
      year: year ?? this.year,
      hasRfid: hasRfid ?? this.hasRfid,
      hasFingerprint: hasFingerprint ?? this.hasFingerprint,
    );
  }
}