import 'package:flutter/material.dart';

class EnterMarksPage extends StatefulWidget {
  final Map<String, dynamic> course;
  
  const EnterMarksPage({super.key, required this.course});

  @override
  State<EnterMarksPage> createState() => _EnterMarksPageState();
}

class _EnterMarksPageState extends State<EnterMarksPage> {
  // Sample students with marks
  final List<Map<String, dynamic>> students = [
    {'id': 'S001', 'name': 'Alice Johnson', 'marks': {
      'attendance': 8.5, 'assignment': 15, 'ct1': 8, 'ct2': 9, 'mid': 18, 'final': 35
    }},
    {'id': 'S002', 'name': 'Bob Smith', 'marks': {
      'attendance': 9, 'assignment': 14, 'ct1': 7, 'ct2': 8, 'mid': 17, 'final': 32
    }},
    {'id': 'S003', 'name': 'Charlie Brown', 'marks': {
      'attendance': 7, 'assignment': 12, 'ct1': 6, 'ct2': 7, 'mid': 15, 'final': 30
    }},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Marks - ${widget.course['code']}'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          // Header with max marks
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  SizedBox(width: 100, child: Text('Student')),
                  SizedBox(width: 70, child: Text('Att(10)')),
                  SizedBox(width: 70, child: Text('Ass(20)')),
                  SizedBox(width: 70, child: Text('CT1(10)')),
                  SizedBox(width: 70, child: Text('CT2(10)')),
                  SizedBox(width: 70, child: Text('Mid(20)')),
                  SizedBox(width: 70, child: Text('Final(40)')),
                ],
              ),
            ),
          ),
          
          // Student marks list
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(student['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(student['id'], style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                          _buildMarkField(student, 'attendance'),
                          _buildMarkField(student, 'assignment'),
                          _buildMarkField(student, 'ct1'),
                          _buildMarkField(student, 'ct2'),
                          _buildMarkField(student, 'mid'),
                          _buildMarkField(student, 'final'),
                        ],
                      ),
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
                onPressed: _saveMarks,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text('SAVE MARKS', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkField(Map<String, dynamic> student, String field) {
    return SizedBox(
      width: 70,
      child: TextFormField(
        initialValue: student['marks'][field].toString(),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        ),
        onChanged: (value) {
          student['marks'][field] = double.tryParse(value) ?? 0;
        },
      ),
    );
  }

  void _saveMarks() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Marks saved successfully!'),
        backgroundColor: Colors.orange,
      ),
    );
    Navigator.pop(context);
  }
}