class ReportSummary {
  final int present;
  final int late;
  final int total;

  ReportSummary({
    required this.present,
    required this.late,
    required this.total,
  });

  double get attendanceRate =>
      total == 0 ? 0 : ((present / total) * 100);
}
