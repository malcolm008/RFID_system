import 'package:flutter/material.dart';
import 'timetable_api.dart';
import 'timetable_model.dart';

class TimetableProvider extends ChangeNotifier {
  final TimetableApi _api = TimetableApi();
  List<TimetableEntry> _entries = [];
  List<TimetableEntry> get entries => _entries;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  int? _filterProgramId;
  int? _filterYear;
  int? _filterTeacherId;
  String? _filterLocation;
  String? _filterDay;
  String? _filterQualification;

  int? get filterProgramId => _filterProgramId;
  int? get filterYear => _filterYear;
  int? get filterTeacherId => _filterTeacherId;
  String? get filterDay => _filterDay;

  void setProgramFilter(int? programId) {
    _filterProgramId = programId;
    _fetchFiltered();
  }

  void setYearFilter(int? year) {
    _filterYear = year;
    _fetchFiltered();
  }

  void setTeacherFilter(int? teacherId) {
    _filterTeacherId = teacherId;
    _fetchFiltered();
  }

  void setLocationFilter(String? location) {
    _filterLocation = location;
    _fetchFiltered();
  }

  void setDayFilter(String? day) {
    _filterDay = day;
    _fetchFiltered();
  }

  void setQualificationFilter(String? qualification) {
    _filterQualification = qualification;
    _fetchFiltered();
  }

  void clearFilters() {
    _filterProgramId = null;
    _filterYear = null;
    _filterTeacherId = null;
    _filterLocation = null;
    _filterDay = null;
    _filterQualification = null;
    _fetchFiltered();
  }

  Future<void> _fetchFiltered() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _entries = await _api.fetchTimetable(
        programId: _filterProgramId,
        year: _filterYear,
        teacherId: _filterTeacherId,
        location: _filterLocation,
        day: _filterDay,
        qualification: _filterQualification,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTimetable() async{
    await _fetchFiltered();
  }

  Future<void> addEntry(Map<String, dynamic> entryData) async {
    try {
      final newEntry = await _api.createEntry(entryData);
      await _fetchFiltered();
      debugPrint('Successfully added entry');
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding entry: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addMultipleEntries(List<Map<String, dynamic>> entriesData) async {
    try {
      final newEntries = await _api.bulkCreateEntries(entriesData);
      await _fetchFiltered();
      debugPrint('Successfully added ${newEntries.length} entries');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateEntry(String id, Map<String, dynamic> entryData) async {
    try {
      final updated = await _api.updateEntry(id, entryData);
      final index = _entries.indexWhere((e) => e.id == id);
      if (index != -1) {
        _entries[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      await _api.deleteEntry(id);
      _entries.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> bulkDeleteEntries(List<String> ids) async {
    try {
      await _api.bulkDeleteEntries(ids);
      _entries.removeWhere((e) => ids.contains(e.id));
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}