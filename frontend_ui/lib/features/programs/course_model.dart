class Course {
  final String id;
  final String name;
  final String code;

  final String qualification;

  final String programId;
  final String? programName;

  final String department;

  final int semester;
  final int year;

  Course({
    required this.id,
    required this.name,
    required this.code,
    required this.qualification,
    required this.programId,
    this.programName,
    required this.department,
    required this.semester,
    required this.year,
});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'].toString(),
      name: json['name'],
      code: json['code'],

      qualification: json['qualification'],

      programId: json['program'].toString(),
      programName: json['program_name'],

      department: json['department'].toString(),

      semester: int.parse(json['semester'].toString()),
      year: int.parse(json['year'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "code": code,
      "qualification": qualification,
      "program": programId,
      "department": department,
      "semester": semester,
      "year": year,
    };
  }
}