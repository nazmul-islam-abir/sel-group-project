import 'package:flutter/material.dart';

class TakeAttendancePage extends StatefulWidget {
  final Map<String, dynamic> course;
  
  const TakeAttendancePage({super.key, required this.course});

  @override
  State<TakeAttendancePage> createState() => _TakeAttendancePageState();
}

class _TakeAttendancePageState extends State<TakeAttendancePage> {
  // Sample students
  final List<Map<String, dynamic>> students = [
    {'id': 'S001', 'name': 'Alice Johnson', 'status': 'Present'},
    {'id': 'S002', 'name': 'Bob Smith', 'status': 'Present'},
    {'id': 'S003', 'name': 'Charlie Brown', 'status': 'Present'},
    {'id': 'S004', 'name': 'Diana Prince', 'status': 'Present'},
  ];

  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance - ${widget.course['code']}'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Date picker
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Date:', style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _selectDate,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Student list
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: Text(student['id'].substring(1)),
                    ),
                    title: Text(student['name']),
                    subtitle: Text('ID: ${student['id']}'),
                    trailing: DropdownButton<String>(
                      value: student['status'],
                      items: const [
                        DropdownMenuItem(value: 'Present', child: Text('Present')),
                        DropdownMenuItem(value: 'Absent', child: Text('Absent')),
                        DropdownMenuItem(value: 'Late', child: Text('Late')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          student['status'] = value!;
                        });
                      },
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
                onPressed: _saveAttendance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('SAVE ATTENDANCE', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void _saveAttendance() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attendance saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }
}