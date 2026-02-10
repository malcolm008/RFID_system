enum ProgramLevel { undergraduate, postgraduate }
enum Qualification {
  Certificate(false),
  Diploma(false),
  Degree(true),
  Masters(false),
  PhD(false);

  final bool hasLevels;
  const Qualification(this.hasLevels);
}

class SchoolClass {
  final String id;
  final String name;
  final Qualification qualification;
  final ProgramLevel? level;
  final String duration;
  final String department;

  SchoolClass({
    required this.id,
    required this.name,
    required this.qualification,
    this.level,
    required this.duration,
    required this.department,
  }){
    if (qualification.hasLevels && level == null) {
      throw ArgumentError('Level required for this qualification');
    }

    if (!qualification.hasLevels && level != null) {
      throw ArgumentError('This qualification does not support levels');
    }
  }
}