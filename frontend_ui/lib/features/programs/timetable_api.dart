import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend_ui/features/programs/timetable_model.dart';

class TimetableApi {
  static const String baseUrl = 'http://127.0.0.1:8000/attendance_api';

  Future<List<TimetableEntry>> fetchTimetable({
    int? programId,
    int? year,
    int? teacherId,
    String? location,
    String? day,
    String? qualification,
}) async {
    final query = <String, String>{};
    if (programId != null) query['program'] = programId.toString();
    if (year != null) query['year'] = year.toString();
    if (teacherId != null) query['teacher'] = teacherId.toString();
    if (location != null && location.isNotEmpty) query['location'] = location;
    if (day != null && day.isNotEmpty) query['day'] = day;
    if (qualification != null && qualification.isNotEmpty) query['qualification'] = qualification;

    final uri = Uri.parse('$baseUrl/timetable/list/').replace(queryParameters: query);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((e) => TimetableEntry.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load timetable: ${response.statusCode}');
    }
  }

  Future<TimetableEntry> createEntry(Map<String, dynamic> entryData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/timetable/create/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(entryData),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return TimetableEntry.fromJson(jsonResponse['data']);
    }else {
      throw Exception('Failed to create timetable entry: ${response.body}');
    }
  }

  Future<List<TimetableEntry>> bulkCreateEntries(List<Map<String, dynamic>> entriesData) async {
    print('🔍 Bulk creating entries: ${json.encode(entriesData)}');

    final response = await http.post(
      Uri.parse('$baseUrl/timetable/bulk-create/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(entriesData),
    );

    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    if (response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((e) => TimetableEntry.fromJson(e)).toList();
    } else {
      throw Exception('Failed to bulk create entries: ${response.body}');
    }
  }

  Future<TimetableEntry> updateEntry(String id, Map<String, dynamic> entryData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/timetable/update/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': id, ...entryData}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return TimetableEntry.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Failed to update timetable entry: ${response.body}');
    }
  }

  Future<void> deleteEntry(String id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/timetable/delete/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': id}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete entry: ${response.body}');
    }
  }

  Future<void> bulkDeleteEntries(List<String> ids) async {
    final response = await http.post(
      Uri.parse('$baseUrl/timetable/bulk-delete/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'ids': ids}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to bulk delete entries: ${response.body}');
    }
  }
}