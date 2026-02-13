import 'package:supabase_flutter/supabase_flutter.dart';

/// This file handles ALL Supabase related work
/// UI pages should NEVER talk to Supabase directly
class SupabaseConnector {
  // Shortcut for Supabase client
  static final SupabaseClient _client = Supabase.instance.client;

  /// Fetch single student data from "students" table
  static Future<Map<String, dynamic>> getStudent() async {
    // Select one row from students table
    final response = await _client
        .from('students')
        .select()
        .single();

    // Return data to UI page
    return response;
  }

  /// 📚 Fetch enrolled courses for a student
  /// Now using the enrollments table
  static Future<List<Map<String, dynamic>>> getEnrolledCourses(
      String studentId) async {
    try {
      final response = await _client
          .from('enrollments')
          .select('''
            course_code,
            course_name,
            status,
            enrollment_date
          ''')
          .eq('student_id', studentId)
          .eq('status', 'active')  // Only get active enrollments
          .order('enrollment_date', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error getting enrolled courses: $e");
      return [];
    }
  }

  /// 📚 Get all enrollments for a student (including dropped/completed)
  static Future<List<Map<String, dynamic>>> getAllEnrollments(
      String studentId) async {
    try {
      final response = await _client
          .from('enrollments')
          .select()
          .eq('student_id', studentId)
          .order('enrollment_date', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error getting all enrollments: $e");
      return [];
    }
  }

  /// 📝 Enroll a student in a course
  static Future<bool> enrollStudent(
      String studentId, 
      String courseCode, 
      String courseName) async {
    try {
      await _client.from('enrollments').insert({
        'student_id': studentId,
        'course_code': courseCode,
        'course_name': courseName,
        'status': 'active',
        'enrollment_date': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print("Error enrolling student: $e");
      return false;
    }
  }

  /// 🔄 Update enrollment status
  static Future<bool> updateEnrollmentStatus(
      int enrollmentId, 
      String newStatus) async {
    try {
      await _client
          .from('enrollments')
          .update({'status': newStatus})
          .eq('id', enrollmentId);
      return true;
    } catch (e) {
      print("Error updating enrollment status: $e");
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getCourseFiles(String courseCode) async {
    try {
      final response = await _client
          .from('course_files')
          .select()
          .eq('course_code', courseCode);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error getting files: $e");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getCourseMaterials(String courseCode) async {
    try {
      final response = await _client
          .from('course_materials')
          .select()
          .eq('course_code', courseCode)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetching course materials: $e");
      return [];
    }
  }

  // 4. GET STUDENT MARKS (with 2 CTs)
  static Future<List<Map<String, dynamic>>> getStudentMarks(String studentId) async {
    try {
      final response = await _client
          .from('student_marks')
          .select('*')
          .eq('student_id', studentId)
          .order('course_code', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error getting marks: $e");
      return [];
    }
  }

  /// 📅 Get student attendance
  static Future<List<Map<String, dynamic>>> getAttendance(String studentId) async {
    try {
      final response = await _client
          .from('attendance')
          .select()
          .eq('student_id', studentId)
          .order('date', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error getting attendance: $e");
      return [];
    }
  }
  
  /// 📅 Get attendance by course
  static Future<List<Map<String, dynamic>>> getCourseAttendance(
      String studentId, 
      String courseCode
  ) async {
    try {
      final response = await _client
          .from('attendance')
          .select()
          .eq('student_id', studentId)
          .eq('course_code', courseCode)
          .order('date', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error getting course attendance: $e");
      return [];
    }
  }

  // ============== TODO FUNCTIONS ==============

  static Future<List<Map<String, dynamic>>> getMyTodos(String studentId) async {
    try {
      final response = await _client
          .from('student_todos')
          .select()
          .eq('student_id', studentId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error loading todos: $e");
      return [];
    }
  }

  static Future<void> addTodo(Map<String, dynamic> todo) async {
    try {
      await _client.from('student_todos').insert(todo);
    } catch (e) {
      print("Error adding todo: $e");
    }
  }

  static Future<void> updateTodo(int id, Map<String, dynamic> updates) async {
    try {
      await _client.from('student_todos').update(updates).eq('id', id);
    } catch (e) {
      print("Error updating todo: $e");
    }
  }

  static Future<void> markTodoCompleted(int id, bool isCompleted) async {
    try {
      await _client
          .from('student_todos')
          .update({'is_completed': isCompleted})
          .eq('id', id);
    } catch (e) {
      print("Error updating todo status: $e");
    }
  }

  static Future<void> deleteTodo(int id) async {
    try {
      await _client.from('student_todos').delete().eq('id', id);
    } catch (e) {
      print("Error deleting todo: $e");
    }
  }
}