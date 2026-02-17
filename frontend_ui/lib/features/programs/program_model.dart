enum ProgramLevel { undergraduate, postgraduate }
enum Qualification {Certificate, Diploma, Degree, Masters, PhD}

class Program {
  final String id;
  final String name;
  final String? abbreviation;
  final Qualification qualification;
  final ProgramLevel? level;
  final int duration;
  final String department;

  Program({
    required this.id,
    required this.name,
    this.abbreviation,
    required this.qualification,
    this.level,
    required this.duration,
    required this.department,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['id'].toString(),
      name: json['name'],
      abbreviation: json['abbreviation'] ?? '',
      qualification: Qualification.values.firstWhere(
          (e) => e.name == json['qualification'],
      ),
      level: json['level'] != null
        ? ProgramLevel.values.firstWhere(
          (e) => e.name == json['level'],
      ) : null,
      duration: int.parse(json['duration'].toString()),
      department: json['department'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id":  id,
      "name": name,
      "abbreviation": abbreviation,
      "qualification": qualification.name,
      "level": level?.name,
      "duration": duration,
      "department": department,
    };
  }
}