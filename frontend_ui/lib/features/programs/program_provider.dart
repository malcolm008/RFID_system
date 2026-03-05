import 'package:flutter/material.dart';
import 'program_model.dart';
import 'program_api.dart';
import 'course_model.dart';
import 'timetable_model.dart';
import '../../core/services/notification_provider.dart';

class ProgramProvider extends ChangeNotifier {
  final List<Program> _programs = [];
  bool _loading = false;
  final NotificationProvider _notificationProvider;

  List<Program> get programs => _programs;
  bool get isLoading => _loading;

  ProgramProvider({required NotificationProvider notificationProvider})
    : _notificationProvider = notificationProvider;

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
      try {
        final newProgram = await ProgramApi.addProgram(program);
        _programs.add(newProgram);
        notifyListeners();

        _notificationProvider.addEnrollmentNotification(
          type: "program",
          name: program.name,
          details: 'Qualification: ${program.qualification}, Code: ${program.abbreviation}'
        );
      } catch (e) {
        debugPrint('Error adding program: $e');
        rethrow;
      }
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