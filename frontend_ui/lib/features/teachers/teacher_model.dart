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
    return Teacher(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      course: json['course'],
      department: json['department'],
      hasRfid: json['hasRfid'] == 1 || json['hasFingerprint'] == true,
      hasFingerprint: json['hasFingerprint'] == 1 || json['hasFingerprint'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "course": course,
      "department": department,
      "hasRfid": hasRfid,
      "hasFingerprint": hasFingerprint,
    };
  }
}

