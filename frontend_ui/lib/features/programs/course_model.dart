class Course {
  final String id;
  final String name;
  final String code;

  final String programId;
  final String departmentId;
  final String teacherId;

  final int semester;
  final int year;

  Course({
    required this.id,
    required this.name,
    required this.code,
    required this.programId,
    required this.departmentId,
    required this.teacherId,
    required this.semester,
    required this.year,
});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'].toString(),
      name: json['name'],
      code: json['code'],
      programId: json['program'].toString(),
      departmentId: json['department'].toString(),
      teacherId: json['teacher'].toString(),
      semester: int.parse(json['semester'].toString()),
      year: int.parse(json['year'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "code": code,
      "program": programId,
      "department": departmentId,
      "teacher": teacherId,
      "semester": semester,
      "year": year,
    };
  }
}