class Course {
  final String id;
  final String name;
  final String code;

  final String qualification;

  final List<String> programIds;
  final List<String>? programNames;
  final List<String> programAbbreviations;


  final int semester;
  final int year;

  Course({
    required this.id,
    required this.name,
    required this.code,
    required this.qualification,
    required this.programIds,
    this.programNames,
    required this.programAbbreviations,
    required this.semester,
    required this.year,
});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'].toString(),
      name: json['name'],
      code: json['code'],

      qualification: json['qualification'],

      programIds: List<String>.from(
        json['programs'].map((p) => p.toString()),
      ),
      programNames: json['program_name'] != null
        ? List<String>.from(json['program_name'])
        : null,
      programAbbreviations: json['program_abbreviations'] != null
          ? List<String>.from(json['program_abbreviations'])
          : [],
      semester: int.parse(json['semester'].toString()),
      year: int.parse(json['year'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id.isNotEmpty ? int.tryParse(id) ?? 0: 0,
      "name": name,
      "code": code,
      "qualification": qualification,
      "programs": programIds,
      "semester": semester,
      "year": year,
    };
  }
}