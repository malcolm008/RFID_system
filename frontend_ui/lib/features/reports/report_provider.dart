import 'package:flutter/material.dart';
import 'report_model.dart';

class ReportProvider extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  ReportSummary get dailySummary {
    // Mock values – backend later
    return ReportSummary(
      present: 210,
      late: 15,
      total: 240,
    );
  }

  ReportSummary get monthlySummary {
    return ReportSummary(
      present: 4200,
      late: 320,
      total: 4800,
    );
  }
}
