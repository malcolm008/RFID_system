import 'package:flutter/material.dart';
import 'program_model.dart';
import 'program_api.dart';
import 'course_model.dart';
import 'timetable_model.dart';

class ProgramProvider extends ChangeNotifier {
  final List<TimetableEntry> timetable = [
    TimetableEntry(
      id: '1',
      program: 'Bsc in Computer Engineering',
      course: 'Data Structures',
      teacherName: 'Mr. John',
      day: 'Monday',
      device: 'RFID 001',
      year: 2,
      location: 'BH 307',
      startTime: '09:00',
      endTime: '11:00',
    ),
    TimetableEntry(
      id: '2',
      program: 'Bsc in Computer Engineering',
      course: 'Operating Systems',
      teacherName: 'Ms. Jane',
      day: 'Tuesday',
      device: 'HYBRID 003',
      year: 1,
      location: 'BH 305',
      startTime: '10:00',
      endTime: '12:00',
    ),
  ];
  final List<Program> _programs = [];
  bool _loading = false;

  List<Program> get programs => _programs;
  bool get isLoading => _loading;

  Future<void> loadPrograms() async {
    _loading = true;
    notifyListeners();

    try {
      final data = await ProgramApi.fetchPrograms();
      _programs
        ..clear()
        ..addAll(data);
    } catch (e, stack) {
      debugPrint('Error loading programs: $e\n$stack');
      // Optionally show a snackbar or keep the old list
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addProgram(Program program) async {
    final newProgram = await ProgramApi.addProgram(program);
    _programs.add(newProgram);
    notifyListeners();
  }

  Future<void> updateProgram(Program program) async {
    final updated = await ProgramApi.updateProgram(program);
    final index = _programs.indexWhere((c) => c.id == updated.id);

    if (index != -1){
      _programs[index] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteProgram(String id) async {
    try {
      await ProgramApi.deleteProgram(id);
      _programs.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting program $id: $e');
      rethrow;
    }
  }

  Future<void> bulkDeletePrograms(List<String> ids) async {
    try {
      await ProgramApi.bulkDeletePrograms(ids);
      _programs.removeWhere((p) => ids.contains(p.id));
      notifyListeners();
    } catch (e) {
      debugPrint('Error bulk deleting programs: $e');
      rethrow;
    }
  }
}