import 'package:flutter/material.dart';
import '../../connectors/supabase_connector.dart';

class TakeAttendancePage extends StatefulWidget {
  final Map<String, dynamic> course;
  
  const TakeAttendancePage({super.key, required this.course});

  @override
  State<TakeAttendancePage> createState() => _TakeAttendancePageState();
}

class _TakeAttendancePageState extends State<TakeAttendancePage> {
  List<Map<String, dynamic>> students = [];
  Map<String, String> attendanceStatus = {}; // student_id -> status
  DateTime selectedDate = DateTime.now();
  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEnrolledStudents();
  }

  Future<void> _loadEnrolledStudents() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final courseCode = widget.course['course_code'] ?? widget.course['code'];
      
      print('📚 Loading enrolled students for course: $courseCode');
      
      // Get enrolled students using the method
      final enrolledStudents = await SupabaseConnector.getEnrolledStudents(courseCode);
      
      print('✅ Received ${enrolledStudents.length} students');
      
      if (enrolledStudents.isEmpty) {
        // Debug: Check what's in enrollments table
        final debugInfo = await SupabaseConnector.debugEnrollments(courseCode);
        print('🔍 Enrollments in DB: $debugInfo');
        
        setState(() {
          students = [];
          isLoading = false;
        });
        return;
      }
      
      // Initialize all enrolled students as 'Present' by default
      for (var student in enrolledStudents) {
        final studentId = student['student_id']?.toString() ?? '';
        if (studentId.isNotEmpty) {
          attendanceStatus[studentId] = 'Present';
        }
      }
      
      setState(() {
        students = enrolledStudents;
        isLoading = false;
      });

    } catch (e) {
      print('❌ Error loading students: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _saveAttendance() async {
    setState(() => isSaving = true);

    try {
      final courseCode = widget.course['course_code'] ?? widget.course['code'];
      
      // Prepare attendance records
      final attendanceRecords = students.map((student) {
        final studentId = student['student_id']?.toString() ?? '';
        return {
          'student_id': studentId,
          'course_code': courseCode,
          'date': selectedDate.toIso8601String().split('T')[0],
          'status': attendanceStatus[studentId] ?? 'Present',
        };
      }).toList();

      print('📝 Saving ${attendanceRecords.length} attendance records');

      await SupabaseConnector.saveAttendance(attendanceRecords);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Attendance saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);

    } catch (e) {
      print('❌ Error saving attendance: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving attendance: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseCode = widget.course['course_code'] ?? widget.course['code'] ?? 'Course';
    final courseName = widget.course['course_name'] ?? widget.course['name'] ?? 'Course';

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance - $courseCode'),
        backgroundColor: Colors.green,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.green))
        : errorMessage != null
          ? _buildErrorWidget()
          : students.isEmpty
            ? _buildEmptyWidget(courseCode)
            : _buildAttendanceWidget(courseName, courseCode),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading enrolled students',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEnrolledStudents,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(String courseCode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No students enrolled',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              'Course: $courseCode',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue.shade700),
            ),
            const SizedBox(height: 20),
            
            // Debug button
            ElevatedButton.icon(
              onPressed: () async {
                final debugInfo = await SupabaseConnector.debugEnrollments(courseCode);
                if (!mounted) return;
                
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Enrollments in Database'),
                    content: Container(
                      width: double.maxFinite,
                      child: debugInfo.isEmpty
                        ? const Text('No enrollments found in database.')
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Current enrollments:'),
                              const SizedBox(height: 8),
                              ...debugInfo.map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '• ${e['student_id']} - ${e['course_code']} (${e['status']})',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              )),
                            ],
                          ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('Check Enrollments'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
            
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadEnrolledStudents,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceWidget(String courseName, String courseCode) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.green.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      courseName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${students.length} Enrolled',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    '${selectedDate.day.toString().padLeft(2, '0')}/'
                    '${selectedDate.month.toString().padLeft(2, '0')}/'
                    '${selectedDate.year}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, size: 20),
                    onPressed: _selectDate,
                    color: Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Legend
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Colors.grey.shade100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('P', 'Present', Colors.green),
              _buildLegendItem('L', 'Late', Colors.orange),
              _buildLegendItem('A', 'Absent', Colors.red),
            ],
          ),
        ),

        // Student list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final studentId = student['student_id']?.toString() ?? '';
              final studentName = student['name']?.toString() ?? 'Unknown';
              final currentStatus = attendanceStatus[studentId] ?? 'Present';

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: Text(
                          studentName.isNotEmpty ? studentName[0].toUpperCase() : '?',
                          style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          studentName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                      _buildStatusButton('Present', studentId, currentStatus, Colors.green),
                      const SizedBox(width: 4),
                      _buildStatusButton('Late', studentId, currentStatus, Colors.orange),
                      const SizedBox(width: 4),
                      _buildStatusButton('Absent', studentId, currentStatus, Colors.red),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Save button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isSaving ? null : _saveAttendance,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('SAVE ATTENDANCE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String letter, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              letter,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      ],
    );
  }

  Widget _buildStatusButton(
    String status,
    String studentId,
    String currentStatus,
    Color color,
  ) {
    final isSelected = currentStatus == status;
    
    return Container(
      margin: const EdgeInsets.only(left: 4),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            attendanceStatus[studentId] = status;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? color : Colors.grey.shade200,
          foregroundColor: isSelected ? Colors.white : Colors.black54,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: const Size(50, 36),
        ),
        child: Text(
          status == 'Present' ? 'P' : status == 'Late' ? 'L' : 'A',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}