class Course {
  final String id;
  final String name;
  final String code;
  final String department;
  final int semester;
  final int year;
  final String teacherName;

  Course({
    required this.id,
    required this.name,
    required this.code,
    required this.department,
    required this.semester,
    required this.year,
    required this.teacherName,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'].toString(),
      name: json['name'],
      code: json['code'],
      department: json['department'],
      semester: int.parse(json['semester'].toString()),
      year: int.parse(json['year'].toString()),
      teacherName: json['teacherName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "code": code,
      "department": department,
      "semester": semester,
      "year": year,
      "teacherName": teacherName,
    };
  }
}