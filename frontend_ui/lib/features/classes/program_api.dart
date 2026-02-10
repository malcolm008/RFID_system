import 'dart:convert';
import 'package:http/http.dart' as http;
import 'program_model.dart';

class ProgramApi{
  static const baseUrl = "http://127.0.0.1:8000/attendance_api/programs";

  static Future<List<Program>> fetchPrograms() async {
    final response = await http.get(Uri.parse("$baseUrl/list/"));
    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final List data = body['data'];
      return data.map((e) => Program.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load programs");
    }
  }

  static Future<Program> addProgram(Program program) async {
    final response = await http.post(
      Uri.parse("$baseUrl/create/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(program.toJson()),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return Program.fromJson(body['data']);
    } else {
      throw Exception(body['errors'] ?? 'Failed to create class');
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