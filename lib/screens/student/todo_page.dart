// todo_page.dart - MINIMAL & CLEAN
import 'package:flutter/material.dart';
import '../../connectors/supabase_connector.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<Map<String, dynamic>> todos = [];
  bool isLoading = true;
  String studentId = '';

  final titleController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadTodos();
  }

  Future<void> loadTodos() async {
    try {
      final student = await SupabaseConnector.getStudent();
      studentId = student['student_id'].toString();
      final data = await SupabaseConnector.getMyTodos(studentId);
      setState(() {
        todos = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : todos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('No tasks', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _showAddDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: const Text('Add Task'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: loadTodos,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: todos.length,
                          itemBuilder: (context, index) {
                            final todo = todos[index];
                            return _buildTodoItem(todo);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: todos.isNotEmpty
          ? FloatingActionButton(
              onPressed: _showAddDialog,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildTodoItem(Map<String, dynamic> todo) {
    final isCompleted = todo['is_completed'] ?? false;
    final dueDate = DateTime.parse(todo['due_date']);
    final now = DateTime.now();
    final daysLeft = dueDate.difference(now).inDays;
    
    // Show alert if due date is tomorrow or today
    bool showAlert = daysLeft <= 1 && !isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: GestureDetector(
          onTap: () => _toggleComplete(todo['id'], !isCompleted),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted ? Colors.green : Colors.grey.shade400,
                width: 2,
              ),
              color: isCompleted ? Colors.green : Colors.transparent,
            ),
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        ),
        title: Text(
          todo['title'] ?? 'Untitled',
          style: TextStyle(
            fontSize: 16,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              _formatDate(dueDate),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: showAlert ? FontWeight.bold : null,
              ),
            ),
            if (showAlert) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: daysLeft < 0 ? Colors.red.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  daysLeft < 0 ? 'Overdue!' : 'Tomorrow!',
                  style: TextStyle(
                    fontSize: 10,
                    color: daysLeft < 0 ? Colors.red : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert, size: 18),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showEditDialog(todo);
            } else if (value == 'delete') {
              _deleteTodo(todo['id']);
            }
          },
        ),
      ),
    );
  }

  void _showAddDialog() {
    titleController.clear();
    selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'CT-2, Assignment, Quiz...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            const Text('Due Date', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => selectedDate = date);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(_formatDate(selectedDate)),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _saveTodo,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> todo) {
    titleController.text = todo['title'] ?? '';
    selectedDate = DateTime.parse(todo['due_date']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Task title',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Due Date', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => selectedDate = date);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(_formatDate(selectedDate)),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _updateTodo(todo['id']),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTodo() async {
    if (titleController.text.isEmpty) return;

    final newTodo = {
      'student_id': studentId,
      'title': titleController.text,
      'due_date': selectedDate.toIso8601String().split('T')[0],
      'is_completed': false,
      'created_at': DateTime.now().toIso8601String(),
    };

    await SupabaseConnector.addTodo(newTodo);
    Navigator.pop(context);
    await loadTodos();
  }

  Future<void> _updateTodo(int id) async {
    if (titleController.text.isEmpty) return;

    final updates = {
      'title': titleController.text,
      'due_date': selectedDate.toIso8601String().split('T')[0],
    };

    await SupabaseConnector.updateTodo(id, updates);
    Navigator.pop(context);
    await loadTodos();
  }

  Future<void> _toggleComplete(int id, bool value) async {
    await SupabaseConnector.markTodoCompleted(id, value);
    await loadTodos();
  }

  Future<void> _deleteTodo(int id) async {
    await SupabaseConnector.deleteTodo(id);
    await loadTodos();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}