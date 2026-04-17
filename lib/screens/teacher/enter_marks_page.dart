import 'package:flutter/material.dart';
import '../../connectors/supabase_connector.dart';

class EnterMarksPage extends StatefulWidget {
  final Map<String, dynamic> course;
  
  const EnterMarksPage({super.key, required this.course});

  @override
  State<EnterMarksPage> createState() => _EnterMarksPageState();
}

class _EnterMarksPageState extends State<EnterMarksPage> {
  List<Map<String, dynamic>> students = [];
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      final courseCode = widget.course['course_code'] ?? widget.course['code'];
      
      // Get enrolled students
      final enrolled = await SupabaseConnector.getEnrolledStudents(courseCode);
      
      // Get existing marks
      final existingMarks = await SupabaseConnector.getCourseMarks(courseCode);
      
      // Combine data
      final studentsWithMarks = enrolled.map((s) {
        final mark = existingMarks.firstWhere(
          (m) => m['student_id'] == s['student_id'],
          orElse: () => {},
        );
        
        return {
          'student_id': s['student_id'],
          'name': s['name'],
          'attendance': mark['attendance'] ?? 0,
          'assignment': mark['assignment'] ?? 0,
          'ct1': mark['ct1'] ?? 0,
          'ct2': mark['ct2'] ?? 0,
          'mid': mark['mid'] ?? 0,
          'final': mark['final_exam'] ?? 0,
        };
      }).toList();

      setState(() {
        students = studentsWithMarks;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveMarks() async {
    setState(() => isSaving = true);

    try {
      final courseCode = widget.course['course_code'] ?? widget.course['code'];
      
      final records = students.map((s) => {
        'student_id': s['student_id'],
        'course_code': courseCode,
        'attendance': s['attendance'],
        'assignment': s['assignment'],
        'ct1': s['ct1'],
        'ct2': s['ct2'],
        'mid': s['mid'],
        'final_exam': s['final'],
      }).toList();

      await SupabaseConnector.saveMarks(records);

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marks saved'), backgroundColor: Colors.orange),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseCode = widget.course['course_code'] ?? widget.course['code'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Marks - $courseCode'),
        backgroundColor: Colors.orange,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : students.isEmpty 
          ? const Center(child: Text('No students enrolled'))
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey.shade200,
                  child: const Row(
                    children: [
                      Expanded(child: Text('Student', style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(width: 40, child: Text('Att', style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(width: 40, child: Text('Ass', style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(width: 40, child: Text('CT1', style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(width: 40, child: Text('CT2', style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(width: 40, child: Text('Mid', style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(width: 40, child: Text('Final', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, i) {
                      final s = students[i];
                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text(s['name'] ?? '')),
                            _buildField(s, 'attendance', 40),
                            _buildField(s, 'assignment', 40),
                            _buildField(s, 'ct1', 40),
                            _buildField(s, 'ct2', 40),
                            _buildField(s, 'mid', 40),
                            _buildField(s, 'final', 40),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _saveMarks,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: isSaving 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('SAVE MARKS'),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildField(Map<String, dynamic> student, String field, double width) {
    return SizedBox(
      width: width,
      child: TextFormField(
        initialValue: student[field].toString(),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        ),
        onChanged: (val) => setState(() => student[field] = int.tryParse(val) ?? 0),
      ),
    );
  }
}