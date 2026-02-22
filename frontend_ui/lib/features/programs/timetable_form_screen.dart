// lib/features/programs/timetable_form_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'program_provider.dart';
import '../teachers/teacher_provider.dart';
import 'course_provider.dart';
import '../devices/device_provider.dart';
import 'timetable_provider.dart';
import 'timetable_model.dart';
import 'course_model.dart';
import 'program_model.dart';
import '../teachers/teacher_model.dart';
import '../devices/device_model.dart';

class TimetableFormScreen extends StatefulWidget {
  final TimetableEntry? existingEntry;

  const TimetableFormScreen({super.key, this.existingEntry});

  @override
  State<TimetableFormScreen> createState() => _TimetableFormScreenState();
}

class _TimetableFormScreenState extends State<TimetableFormScreen> {
  List<Map<String, dynamic>> _entries = [];
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Days of week
  final List<String> _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    _initializeEntries();
  }

  void _initializeEntries() {
    if (widget.existingEntry != null) {
      // For editing, convert the existing entry to a map
      _entries = [_entryToMap(widget.existingEntry!)];
    } else {
      // Start with one empty entry for creation
      _addEmptyEntry();
    }
  }

  Map<String, dynamic> _entryToMap(TimetableEntry entry) {
    return {
      'programId': entry.program,      // Will be replaced with actual ID mapping
      'programName': entry.program,
      'courseId': entry.course,
      'courseName': entry.course,
      'teacherId': entry.teacherName,
      'teacherName': entry.teacherName,
      'deviceId': entry.device,
      'deviceName': entry.device,
      'day': entry.day,
      'startTime': entry.startTime,
      'endTime': entry.endTime,
      'qualification': entry.qualification,
      'location': entry.location,
      'year': entry.year,
    };
  }

  void _addEmptyEntry() {
    setState(() {
      _entries.add({
        'programId': null,
        'programName': null,
        'courseId': null,
        'courseName': null,
        'teacherId': null,
        'teacherName': null,
        'deviceId': null,
        'deviceName': null,
        'day': null,
        'startTime': null,
        'endTime': null,
        'qualification': '',
        'location': '',
        'year': 1,
      });
    });
  }

  void _removeEntry(int index) {
    setState(() {
      _entries.removeAt(index);
    });
  }

  // Helper to find program by ID
  Program? _findProgramById(String? id, List<Program> programs) {
    if (id == null) return null;
    try {
      return programs.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Helper to find course by ID
  Course? _findCourseById(String? id, List<Course> courses) {
    if (id == null) return null;
    try {
      return courses.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // Helper to find teacher by ID
  Teacher? _findTeacherById(String? id, List<Teacher> teachers) {
    if (id == null) return null;
    try {
      return teachers.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  // Helper to find device by ID
  Device? _findDeviceById(String? id, List<Device> devices) {
    if (id == null) return null;
    try {
      return devices.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  // In _validateAllEntries function, add debug prints
  bool _validateAllEntries() {
    for (var entry in _entries) {
      print('Validating entry:');
      print('  programId: ${entry['programId']}');
      print('  courseId: ${entry['courseId']}');
      print('  teacherId: ${entry['teacherId']}');
      print('  day: ${entry['day']}');
      print('  startTime: ${entry['startTime']}');
      print('  endTime: ${entry['endTime']}');

      if (entry['programId'] == null ||
          entry['courseId'] == null ||
          entry['teacherId'] == null ||
          entry['day'] == null ||
          entry['startTime'] == null ||
          entry['endTime'] == null) {
        print('  ❌ Validation failed');
        return false;
      }
      print('  ✅ Validation passed');
    }
    return true;
  }

  List<Map<String, dynamic>> _prepareApiData() {
    return _entries.map((e) {
      return {
        'program': int.tryParse(e['programId']?.toString() ?? ''), // Convert to int if needed
        'course': int.tryParse(e['courseId']?.toString() ?? ''),
        'teacher': int.tryParse(e['teacherId']?.toString() ?? ''),
        'device': e['deviceId'] != null ? int.tryParse(e['deviceId'].toString()) : null,
        'location': e['location'] ?? '',
        'year': e['year'] ?? 1,
        'day': e['day'] ?? '',
        'start_time': e['startTime'] ?? '',  // Ensure it's never null
        'end_time': e['endTime'] ?? '',      // Ensure it's never null
        'qualification': e['qualification'] ?? '',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final programProvider = Provider.of<ProgramProvider>(context, listen: true);
    final courseProvider = Provider.of<CourseProvider>(context, listen: true);
    final teacherProvider = Provider.of<TeacherProvider>(context, listen: true);
    final deviceProvider = Provider.of<DeviceProvider>(context, listen: true);
    final timetableProvider = Provider.of<TimetableProvider>(context, listen: false);

    // Load data if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (programProvider.programs.isEmpty) programProvider.loadPrograms();
      if (courseProvider.courses.isEmpty) courseProvider.loadCourses();
      if (teacherProvider.teachers.isEmpty) teacherProvider.loadTeachers();
      if (deviceProvider.devices.isEmpty) deviceProvider.loadDevices();
    });

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Container(
        width: 700,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.all(24),
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
                    child: const Icon(Icons.schedule, color: Colors.blue, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.existingEntry == null ? 'Add Schedule(s)' : 'Edit Schedule',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.existingEntry == null
                              ? 'Fill in details for one or multiple schedules'
                              : 'Update the schedule details',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Loading indicator
              if (programProvider.isLoading ||
                  courseProvider.isLoading ||
                  teacherProvider.isLoading ||
                  deviceProvider.isLoading)
                const Center(child: CircularProgressIndicator()),

              // Entry list
              if (!programProvider.isLoading &&
                  !courseProvider.isLoading &&
                  !teacherProvider.isLoading &&
                  !deviceProvider.isLoading)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Preview section
                        if (_entries.isNotEmpty) _buildPreviewSection(),

                        const SizedBox(height: 16),

                        // Entry cards
                        ...List.generate(_entries.length, (index) {
                          return _buildEntryCard(
                            index,
                            _entries[index],
                            programProvider,
                            courseProvider,
                            teacherProvider,
                            deviceProvider,
                          );
                        }),

                        // Add another button
                        if (widget.existingEntry == null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Center(
                              child: TextButton.icon(
                                onPressed: _addEmptyEntry,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Another Schedule'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                      if (_formKey.currentState!.validate() && _validateAllEntries()) {
                        final apiData = _prepareApiData();

                        // 🔍 DEBUG: Print the exact data being sent
                        print('🔍 SENDING DATA TO API:');
                        for (var entry in apiData) {
                          print('  Entry:');
                          print('    program: ${entry['program']} (${entry['program'].runtimeType})');
                          print('    course: ${entry['course']} (${entry['course'].runtimeType})');
                          print('    teacher: ${entry['teacher']} (${entry['teacher'].runtimeType})');
                          print('    device: ${entry['device']} (${entry['device'].runtimeType})');
                          print('    location: ${entry['location']}');
                          print('    year: ${entry['year']}');
                          print('    day: ${entry['day']}');
                          print('    start_time: ${entry['start_time']}');
                          print('    end_time: ${entry['end_time']}');
                          print('    qualification: ${entry['qualification']}');
                        }

                        setState(() => _isLoading = true);

                        try {

                          if (widget.existingEntry != null) {
                            await timetableProvider.updateEntry(
                              widget.existingEntry!.id,
                              apiData.first,
                            );
                          } else {
                            await timetableProvider.addMultipleEntries(apiData);
                          }

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  widget.existingEntry == null
                                      ? 'Schedules added successfully'
                                      : 'Schedule updated successfully',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all required fields'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : Text(widget.existingEntry == null ? 'Save All' : 'Update'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Preview section showing a summary of entries by day
  Widget _buildPreviewSection() {
    final Map<String, List<Map<String, dynamic>>> entriesByDay = {};

    // Initialize with all days
    for (var day in _days) {
      entriesByDay[day] = [];
    }

    // Group entries by day
    for (var entry in _entries) {
      if (entry['day'] != null) {
        entriesByDay[entry['day']]!.add(entry);
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview, size: 20, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                'Preview (${_entries.length} schedule${_entries.length > 1 ? 's' : ''})',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _days.map((day) {
                final dayEntries = entriesByDay[day]!;
                if (dayEntries.isEmpty) return const SizedBox();

                return Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: _getDayColor(day).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          day,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _getDayColor(day),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...dayEntries.map((entry) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry['courseName'] ?? 'Unknown Course',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${entry['startTime']} - ${entry['endTime']}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Individual entry card
  Widget _buildEntryCard(
      int index,
      Map<String, dynamic> entry,
      ProgramProvider programProvider,
      CourseProvider courseProvider,
      TeacherProvider teacherProvider,
      DeviceProvider deviceProvider,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with entry number and remove button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Entry ${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                const Spacer(),
                if (_entries.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => _removeEntry(index),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Program dropdown
            _buildDropdownField<String?>(
              value: entry['programId'],
              label: 'Program *',
              hint: 'Select Program',
              items: programProvider.programs.map((p) {
                return DropdownMenuItem<String?>(
                  value: p.id,
                  child: Text(p.name),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  entry['programId'] = val;
                  final program = _findProgramById(val, programProvider.programs);
                  entry['programName'] = program?.name;

                  if (program != null) {
                    entry['qualification'] = program.qualification.name;
                  }
                  // Reset course when program changes
                  entry['courseId'] = null;
                  entry['courseName'] = null;
                });
              },
              validator: (val) => val == null ? 'Required' : null,
            ),

            const SizedBox(height: 12),

            // Course dropdown (filtered by selected program)
            _buildDropdownField<String?>(
              value: entry['courseId'],
              label: 'Course *',
              hint: 'Select Course',
              items: courseProvider.courses
                  .where((c) => entry['programId'] == null || c.programIds.contains(entry['programId']))
                  .map((c) {
                return DropdownMenuItem<String?>(
                  value: c.id,
                  child: Text(c.name),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  entry['courseId'] = val;
                  final course = _findCourseById(val, courseProvider.courses);
                  entry['courseName'] = course?.name;
                  if (course != null) {
                    entry['year'] = course.year;
                  }
                });
              },
              validator: (val) => val == null ? 'Required' : null,
            ),

            const SizedBox(height: 12),

            // Teacher dropdown
            _buildDropdownField<String?>(
              value: entry['teacherId'],
              label: 'Teacher *',
              hint: 'Select Teacher',
              items: teacherProvider.teachers.map((t) {
                return DropdownMenuItem<String?>(
                  value: t.id,
                  child: Text(t.name),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  entry['teacherId'] = val;
                  final teacher = _findTeacherById(val, teacherProvider.teachers);
                  entry['teacherName'] = teacher?.name;
                });
              },
              validator: (val) => val == null ? 'Required' : null,
            ),

            const SizedBox(height: 12),

            // Device dropdown (optional)
            _buildDropdownField<String?>(
              value: entry['deviceId'],
              label: 'Device (Optional)',
              hint: 'Select Device',
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('None'),
                ),
                ...deviceProvider.devices.map((d) {
                  return DropdownMenuItem<String?>(
                    value: d.id,
                    child: Text(d.name),
                  );
                }).toList(),
              ],
              onChanged: (val) {
                setState(() {
                  entry['deviceId'] = val;
                  if (val != null) {
                    final device = _findDeviceById(val, deviceProvider.devices);
                    entry['deviceName'] = device?.name;
                    // Auto-fill location from device
                    entry['location'] = device?.location ?? '';
                  } else {
                    entry['deviceName'] = null;
                    entry['location'] = '';
                  }
                });
              },
            ),

            const SizedBox(height: 12),

            // Year field
            TextFormField(
              initialValue: entry['year']?.toString(),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Year *',
                hintText: 'e.g., 1, 2, 3, 4',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (val) {
                entry['year'] = int.tryParse(val) ?? 1;
              },
              validator: (val) {
                if (val == null || val.isEmpty) return 'Required';
                if (int.tryParse(val) == null) return 'Invalid year';
                return null;
              },
            ),

            const SizedBox(height: 12),

            // Day dropdown
            _buildDropdownField<String?>(
              value: entry['day'],
              label: 'Day *',
              hint: 'Select Day',
              items: _days.map((day) {
                return DropdownMenuItem<String?>(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
              onChanged: (val) => setState(() => entry['day'] = val),
              validator: (val) => val == null ? 'Required' : null,
            ),

            const SizedBox(height: 12),

            // Time row - REPLACE the entire Row with this
            Row(
              children: [
                Expanded(
                  child: _buildTimeField(
                    label: 'Start Time *',
                    time: entry['startTime'],
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          entry['startTime'] = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                        });
                        // Manually trigger validation
                        _formKey.currentState?.validate();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTimeField(
                    label: 'End Time *',
                    time: entry['endTime'],
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          entry['endTime'] = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                        });
                        // Manually trigger validation
                        _formKey.currentState?.validate();
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Auto-filled fields (read-only) - REPLACE the entire Row with this
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Qualification (auto)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry['qualification']?.isNotEmpty == true
                              ? entry['qualification']
                              : 'Not set',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: entry['qualification']?.isNotEmpty == true
                                ? Colors.black
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location (auto)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry['location']?.isNotEmpty == true
                              ? entry['location']
                              : 'Not set',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: entry['location']?.isNotEmpty == true
                                ? Colors.black
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Reusable dropdown field builder
  Widget _buildDropdownField<T>({
    required T? value,
    required String label,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      hint: Text(hint),
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      isExpanded: true,
    );
  }

  // Time field builder - REPLACE the entire _buildTimeField function with this
  Widget _buildTimeField({
    required String label,
    required String? time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: time == null ? Colors.red.shade300 : Colors.grey.shade400,
            width: time == null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: time == null ? Colors.red.shade50 : Colors.grey.shade50,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: time == null ? Colors.red.shade700 : Colors.grey.shade600,
                      fontWeight: time == null ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time ?? 'Required - tap to select',
                    style: TextStyle(
                      fontWeight: time != null ? FontWeight.w600 : FontWeight.normal,
                      color: time != null ? Colors.black : Colors.red.shade400,
                      fontStyle: time == null ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.access_time,
              size: 20,
              color: time == null ? Colors.red.shade400 : Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  // Get color for day
  Color _getDayColor(String day) {
    switch (day) {
      case 'Monday': return Colors.blue;
      case 'Tuesday': return Colors.green;
      case 'Wednesday': return Colors.orange;
      case 'Thursday': return Colors.purple;
      case 'Friday': return Colors.red;
      case 'Saturday': return Colors.teal;
      case 'Sunday': return Colors.pink;
      default: return Colors.grey;
    }
  }
}