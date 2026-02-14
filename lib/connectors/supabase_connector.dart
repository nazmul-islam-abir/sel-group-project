import 'package:supabase_flutter/supabase_flutter.dart';

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

  /// 👥 Get enrolled students for a course from the enrollments table
  static Future<List<Map<String, dynamic>>> getEnrolledStudents(String courseCode) async {
    try {
      print('🔍 Getting enrolled students for course: $courseCode');
      
      // First, get all student_ids from enrollments table for this course
      final enrollmentResponse = await _client
          .from('enrollments')
          .select('student_id')
          .eq('course_code', courseCode)
          .eq('status', 'active');
      
      print('📊 Enrollment response: $enrollmentResponse');
      
      if (enrollmentResponse.isEmpty) {
        print('⚠️ No enrollments found for course: $courseCode');
        return [];
      }
      
      // Extract student IDs
      final studentIds = enrollmentResponse
          .map<String>((e) => e['student_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
      
      print('📋 Student IDs from enrollments: $studentIds');
      
      if (studentIds.isEmpty) {
        return [];
      }
      
      // Now get student details from students table
      final studentsResponse = await _client
          .from('students')
          .select()
          .inFilter('student_id', studentIds);
      
      print('👥 Students from students table: $studentsResponse');
      
      // Format the response
      final students = studentsResponse.map((student) {
        return {
          'student_id': student['student_id']?.toString() ?? '',
          'id': student['student_id']?.toString() ?? '',
          'name': student['name']?.toString() ?? 'Unknown',
          'email': student['email']?.toString() ?? '',
          'department': student['department']?.toString() ?? '',
          'semester': student['semester']?.toString() ?? '',
        };
      }).toList();
      
      print('✅ Found ${students.length} enrolled students with details');
      return students;
      
    } catch (e) {
      print('❌ Error getting enrolled students: $e');
      return [];
    }
  }

  /// 🔍 Debug method to check enrollments
  static Future<List<Map<String, dynamic>>> debugEnrollments(String courseCode) async {
    try {
      print('🔍 Debugging enrollments for course: $courseCode');
      
      final response = await _client
          .from('enrollments')
          .select()
          .eq('course_code', courseCode);
      
      print('📊 Debug enrollment response: $response');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error debugging enrollments: $e');
      return [];
    }
  }

  /// 👥 Get students by course - (using enrollments table)
  static Future<List<Map<String, dynamic>>> getStudentsByCourse(String courseCode) async {
    try {
      // First get all student_ids from enrollments table for this course
      final enrollmentResponse = await _client
          .from('enrollments')
          .select('student_id')
          .eq('course_code', courseCode)
          .eq('status', 'active');
      
      if (enrollmentResponse.isEmpty) {
        print('No students found enrolled in course: $courseCode');
        return [];
      }
      
      // Extract student IDs
      final studentIds = enrollmentResponse
          .map<String>((e) => e['student_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
      
      if (studentIds.isEmpty) {
        return [];
      }
      
      print('Found ${studentIds.length} students enrolled in course: $courseCode');
      
      // Get student details from students table using the IDs
      final studentsResponse = await _client
          .from('students')
          .select()
          .inFilter('student_id', studentIds);
      
      // Format the response
      return studentsResponse.map((student) {
        return {
          'id': student['id']?.toString() ?? '',
          'student_id': student['student_id']?.toString() ?? '',
          'name': student['name']?.toString() ?? 'Unknown',
          'email': student['email']?.toString() ?? '',
          'department': student['department']?.toString() ?? '',
          'semester': student['semester']?.toString() ?? '',
        };
      }).toList();
      
    } catch (e) {
      print('Error getting students by course: $e');
      return [];
    }
  }

  /// 📝 Save attendance to attendance table
  static Future<void> saveAttendance(List<Map<String, dynamic>> attendanceRecords) async {
    try {
      // Validate records before inserting
      if (attendanceRecords.isEmpty) {
        throw Exception('No attendance records to save');
      }

      // Ensure each record has required fields
      final validRecords = attendanceRecords.where((record) {
        return record.containsKey('student_id') && 
               record.containsKey('course_code') && 
               record.containsKey('date') && 
               record.containsKey('status');
      }).toList();

      if (validRecords.isEmpty) {
        throw Exception('No valid attendance records to save');
      }

      // Insert attendance records into attendance table
      await _client.from('attendance').insert(validRecords);
      
      print('Attendance saved successfully: ${validRecords.length} records');
      
    } catch (e) {
      print('Error saving attendance: $e');
      rethrow;
    }
  }

  /// 📝 Get attendance for a specific date and course
  static Future<List<Map<String, dynamic>>> getAttendanceByDate(
    String courseCode, 
    String date
  ) async {
    try {
      final response = await _client
          .from('attendance')
          .select()
          .eq('course_code', courseCode)
          .eq('date', date);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting attendance by date: $e');
      return [];
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
      
      return [];
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