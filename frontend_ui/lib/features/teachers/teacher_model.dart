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

  factory Teacher.fromJson(Map<String, dynamic> json) {
    print("Parsing JSON: $json");

    return Teacher(
      id: json['id'].toString() ?? '0',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      course: json['course']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      hasRfid: json['hasRfid'] == 1 || json['hasFingerprint'] == true,
      hasFingerprint: json['hasFingerprint'] == 1 || json['hasFingerprint'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id.isNotEmpty ? int.tryParse(id) ?? 0: 0,
      "name": name,
      "email": email,
      "course": course,
      "department": department,
      "hasRfid": hasRfid ? 1 : 0,
      "hasFingerprint": hasFingerprint ? 1 : 0,
    };
  }

  Teacher copyWith({
    String? id,
    String? name,
    String? email,
    String? course,
    String? department,
    bool? hasRfid,
    bool? hasFingerprint,
}) {
    return Teacher(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      course: course ?? this.course,
      department: department ?? this.department,
      hasRfid: hasRfid ?? this.hasRfid,
      hasFingerprint: hasFingerprint ?? this.hasFingerprint,
    );
  }
}

