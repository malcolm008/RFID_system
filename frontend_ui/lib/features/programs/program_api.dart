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
    final Map<String, dynamic> data = program.toJson();
    data.remove('id'); // don't send temporary ID

    print('📤 Sending POST to create program: $data');

    final response = await http.post(
      Uri.parse("$baseUrl/create/"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');  // <-- important

    if (response.statusCode == 201) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return Program.fromJson(json['data']);
    } else {
      // Try to parse error details
      String errorMsg = 'Failed to add program: ${response.statusCode}';
      try {
        final Map<String, dynamic> errorJson = jsonDecode(response.body);
        if (errorJson.containsKey('message')) {
          errorMsg += ' - ${errorJson['message']}';
        }
      } catch (_) {}
      throw Exception(errorMsg);
    }
  }

  static Future<void> deleteProgram(String id) async {
    final response = await http.post(
      Uri.parse("$baseUrl/delete/"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"id": int.parse(id)}),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['status'] == 'success') {
      print("Program deleted: $id");
    } else {
      throw Exception(body['message'] ?? 'Failed to delete program');
    }
  }

  static Future<void> bulkDeleteProgram(List<String> ids) async {
    final response = await http.post(
      Uri.parse("$baseUrl/bulk-delete/"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"ids": ids.map((e) => int.parse(e)).toList()}),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['status'] == 'success') {
      print("Programs deleted: ${ids.join(', ')}");
    } else {
      throw Exception(body['message'] ?? 'Failed to bulk delete programs');
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