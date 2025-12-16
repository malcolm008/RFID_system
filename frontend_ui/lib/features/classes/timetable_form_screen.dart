import 'package:flutter/material.dart';
import 'timetable_model.dart';

class TimetableFormScreen extends StatefulWidget {
  final TimetableEntry? existingEntry;

  const TimetableFormScreen({
    super.key,
    this.existingEntry,
  });

  @override
  State<TimetableFormScreen> createState() => _TimetableFormScreenState();
}

class _TimetableFormScreenState extends State<TimetableFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _prog;
  String? _course;
  String? _teacher;
  String? _day;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final programs = ['Bsc in Computer Engineering and Information Technology', 'Bsc in Business Information and technology'];
  final courses = ['Data Structures', 'Operating Systems'];
  final teachers = ['Mr. John', 'Ms. Jane'];
  final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

  Future<void> _pickTime(bool isStart) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        isStart ? _startTime = time : _endTime = time;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.existingEntry != null) {
      final e = widget.existingEntry!;
      _prog = e.program;
      _course = e.course;
      _teacher = e.teacherName;
      _day = e.day;

      _startTime = _parseTime(e.startTime);
      _endTime = _parseTime(e.endTime);
    }
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: Container(
        width: 550,
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.schedule,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Schedule',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fill in the schedule details below',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Form Fields
              SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDropdownField(
                      context: context,
                      value: _prog,
                      label: 'Program',
                      hintText: 'Select program',
                      icon: Icons.class_,
                      items: programs,
                      onChanged: (value) => setState(() => _prog = value),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a program';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildDropdownField(
                      context: context,
                      value: _course,
                      label: 'Course',
                      hintText: 'Select course',
                      icon: Icons.subject,
                      items: courses,
                      onChanged: (value) => setState(() => _course = value),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a course';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildDropdownField(
                      context: context,
                      value: _teacher,
                      label: 'Teacher',
                      hintText: 'Select teacher',
                      icon: Icons.person,
                      items: teachers,
                      onChanged: (value) => setState(() => _teacher = value),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a teacher';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildDropdownField(
                      context: context,
                      value: _day,
                      label: 'Day',
                      hintText: 'Select day',
                      icon: Icons.calendar_today,
                      items: days,
                      onChanged: (value) => setState(() => _day = value),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a day';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Time Selection
                    Text(
                      'Time Schedule',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeButton(
                            context: context,
                            time: _startTime,
                            label: 'Start Time',
                            onPressed: () => _pickTime(true),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 40,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.grey.shade500,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTimeButton(
                            context: context,
                            time: _endTime,
                            label: 'End Time',
                            onPressed: () => _pickTime(false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      'Cancel',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() &&
                          _startTime != null &&
                          _endTime != null) {
                        // provider.addTimetable(...)
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add Schedule',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required BuildContext context,
    required String? value,
    required String label,
    required String hintText,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
    required String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.white,
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  icon,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
            items: items
                .map((item) => DropdownMenuItem(
              value: item,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _getDropdownColor(item).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _getDropdownIcon(item),
                      size: 16,
                      color: _getDropdownColor(item),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ))
                .toList(),
            onChanged: onChanged,
            validator: validator,
            style: theme.textTheme.bodyMedium,
            dropdownColor: Colors.white,
            icon: Icon(
              Icons.arrow_drop_down,
              color: Colors.grey.shade600,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeButton({
    required BuildContext context,
    required TimeOfDay? time,
    required String label,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.access_time,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        time != null
                            ? time.format(context)
                            : 'Select time',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: time != null
                              ? Colors.green
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getDropdownColor(String item) {
    if (programs.contains(item)) return Colors.blue;
    if (courses.contains(item)) return Colors.purple;
    if (teachers.contains(item)) return Colors.orange;
    if (days.contains(item)) return Colors.green;
    return Colors.grey;
  }

  IconData _getDropdownIcon(String item) {
    if (programs.contains(item)) return Icons.class_;
    if (courses.contains(item)) return Icons.subject;
    if (teachers.contains(item)) return Icons.person;
    if (days.contains(item)) return Icons.calendar_today;
    return Icons.help;
  }
}