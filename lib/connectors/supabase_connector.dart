import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

/// This file handles ALL Supabase related work
/// UI pages should NEVER talk to Supabase directly
class SupabaseConnector {
  // Shortcut for Supabase client
  static final SupabaseClient _client = Supabase.instance.client;

  /// ==================== STUDENT METHODS ====================

  /// Fetch single student data from "students" table
  static Future<Map<String, dynamic>> getStudent() async {
    try {
      final response = await _client
          .from('students')
          .select()
          .single();
      return response;
    } catch (e) {
      print("Error getting student: $e");
      return {};
    }
  }

  /// 📚 Fetch enrolled courses for a student
  static Future<List<Map<String, dynamic>>> getEnrolledCourses(String studentId) async {
    try {
      final response = await _client
          .from('enrolled_courses')
          .select()
          .eq('student_id', studentId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error getting enrolled courses: $e");
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

  /// 📊 Get student marks
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

  /// ==================== TEACHER METHODS ====================

  /// 👨‍🏫 Get teacher information
  static Future<Map<String, dynamic>> getTeacher() async {
    try {
      // For now, return mock data for testing
      return {
        'teacher_id': 'T001',
        'name': 'Dr. John Smith',
        'email': 'john.smith@university.edu',
        'department': 'Computer Science',
        'designation': 'Professor',
      };
    } catch (e) {
      print('Error getting teacher: $e');
      return {};
    }
  }

  /// 📚 Get courses taught by a teacher
  static Future<List<Map<String, dynamic>>> getTeacherCourses(String teacherId) async {
    try {
      final response = await _client
          .from('courses')
          .select()
          .eq('teacher_id', teacherId);
      
      if (response.isNotEmpty) {
        return List<Map<String, dynamic>>.from(response);
      }
      
      // Mock data for testing
      return [
        {
          'code': 'CSE101',
          'name': 'Introduction to Programming',
          'semester': 1,
          'students': 45,
        },
        {
          'code': 'CSE203',
          'name': 'Data Structures',
          'semester': 2,
          'students': 38,
        },
        {
          'code': 'CSE305',
          'name': 'Database Systems',
          'semester': 3,
          'students': 42,
        },
      ];
    } catch (e) {
      print('Error getting teacher courses: $e');
      return [];
    }
  }

  /// 👥 Get students by course
  static Future<List<Map<String, dynamic>>> getStudentsByCourse(String courseCode) async {
    try {
      // You need an enrollments table for this
      // For now, return mock data
      return [
        {'id': 'S001', 'name': 'Alice Johnson', 'email': 'alice@student.edu'},
        {'id': 'S002', 'name': 'Bob Smith', 'email': 'bob@student.edu'},
        {'id': 'S003', 'name': 'Charlie Brown', 'email': 'charlie@student.edu'},
        {'id': 'S004', 'name': 'Diana Prince', 'email': 'diana@student.edu'},
      ];
    } catch (e) {
      print('Error getting students: $e');
      return [];
    }
  }

  /// 📝 Save attendance
  static Future<void> saveAttendance(List<Map<String, dynamic>> attendanceRecords) async {
    try {
      await _client.from('attendance').insert(attendanceRecords);
    } catch (e) {
      print('Error saving attendance: $e');
      rethrow;
    }
  }

  /// 📊 Get course marks
  static Future<List<Map<String, dynamic>>> getCourseMarks(String courseCode) async {
    try {
      final response = await _client
          .from('student_marks')
          .select()
          .eq('course_code', courseCode);
      
      if (response.isNotEmpty) {
        return List<Map<String, dynamic>>.from(response);
      }
      
      // Mock data
      return [
        {'student_id': 'S001', 'name': 'Alice Johnson', 'attendance': 8.5, 'assignment': 15, 'ct1': 8, 'ct2': 9, 'mid': 18, 'final': 35},
        {'student_id': 'S002', 'name': 'Bob Smith', 'attendance': 9, 'assignment': 14, 'ct1': 7, 'ct2': 8, 'mid': 17, 'final': 32},
      ];
    } catch (e) {
      print('Error getting course marks: $e');
      return [];
    }
  }

  /// 📊 Save marks
  static Future<void> saveMarks(List<Map<String, dynamic>> marksRecords) async {
    try {
      await _client.from('student_marks').upsert(marksRecords);
    } catch (e) {
      print('Error saving marks: $e');
      rethrow;
    }
  }

  /// 📤 Upload course material
  static Future<void> uploadCourseMaterial(Map<String, dynamic> material) async {
    try {
      await _client.from('course_materials').insert(material);
    } catch (e) {
      print('Error uploading material: $e');
      rethrow;
    }
  }
}