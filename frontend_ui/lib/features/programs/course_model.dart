class Course {
  final String id;
  final String name;
  final String code;

  final String programId;
  final String? programName;
  final String department;

  final int semester;
  final int year;

  Course({
    required this.id,
    required this.name,
    required this.code,
    required this.programId,
    required this.department,
    this.programName,
    required this.semester,
    required this.year,
});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'].toString(),
      name: json['name'],
      code: json['code'],
      programId: json['program'].toString(),
      department: json['department'].toString(),
      programName: json['program_name'],
      semester: int.parse(json['semester'].toString()),
      year: int.parse(json['year'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "code": code,
      "program": programId,
      "department": department,
      "semester": semester,
      "year": year,
    };
  }
}