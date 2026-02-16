import 'dart:convert';
import 'package:http/http.dart' as http;
import 'program_model.dart';

class ProgramApi{
  static const baseUrl = "http://127.0.0.1:8000/attendance_api/programs";


  static Future<List<Program>> fetchPrograms() async {
    final response = await http.get(Uri.parse("$baseUrl/list/"));
    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      // The actual list is inside json['data']
      final List<dynamic> programsJson = json['data'];
      return programsJson.map((e) => Program.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load programs: ${response.statusCode}');
    }
  }

  static Future<Program> addProgram(Program program) async {
    final response = await http.post(
      Uri.parse("$baseUrl/create/"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(program.toJson()),
    );
    if (response.statusCode == 201) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      // The created program is inside json['data']
      return Program.fromJson(json['data']);
    } else {
      throw Exception('Failed to add program: ${response.statusCode}');
    }
  }

  static Future<Program> updateProgram(Program program) async {
    final response = await http.post(
      Uri.parse("$baseUrl/update/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(program.toJson()),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Program.fromJson(body['data']);
    } else {
      throw Exception(body['errors'] ?? 'Failed to update program');
    }
  }
}