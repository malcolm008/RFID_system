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

    final uri = Uri.parse('$baseUrl/timetable/').replace(queryParameters: query);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((e) => TimetableEntry.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load timetable: ${response.statusCode}');
    }
  }
}