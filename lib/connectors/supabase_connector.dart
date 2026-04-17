import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:typed_data';

/// This file handles ALL Supabase related work
/// UI pages should NEVER talk to Supabase directly
class SupabaseConnector {
  // Shortcut for Supabase client
  static final SupabaseClient _client = Supabase.instance.client;

  /// ==================== STUDENT METHODS ====================

  /// Fetch single student data from "students" table
  static Future<Map<String, dynamic>> getStudent() async {
    try {
      final response = await _client.from('students').select().single();
      return response;
    } catch (e) {
      print("Error getting student: $e");
      return {};
    }
  }

  /// 📚 Fetch enrolled courses for a student (using enrollments table)
  static Future<List<Map<String, dynamic>>> getEnrolledCourses(
    String studentId,
  ) async {
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
          .eq('status', 'active')
          .order('enrollment_date', ascending: false);

      print(
        "📚 Found ${response.length} enrolled courses for student $studentId",
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("❌ Error getting enrolled courses: $e");
      return [];
    }
  }

  /// 📚 Get all enrollments for a student (including dropped/completed)
  static Future<List<Map<String, dynamic>>> getAllEnrollments(
    String studentId,
  ) async {
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
    String courseName,
  ) async {
    try {
      await _client.from('enrollments').insert({
        'student_id': studentId,
        'course_code': courseCode,
        'course_name': courseName,
        'status': 'active',
        'enrollment_date': DateTime.now().toIso8601String(),
      });
      print("✅ Student $studentId enrolled in $courseCode");
      return true;
    } catch (e) {
      print("❌ Error enrolling student: $e");
      return false;
    }
  }

  /// 🔄 Update enrollment status
  static Future<bool> updateEnrollmentStatus(
    int enrollmentId,
    String newStatus,
  ) async {
    try {
      await _client
          .from('enrollments')
          .update({'status': newStatus})
          .eq('id', enrollmentId);
      print("✅ Enrollment $enrollmentId status updated to $newStatus");
      return true;
    } catch (e) {
      print("❌ Error updating enrollment status: $e");
      return false;
    }
  }

  /// 📁 Get course files from course_files table
  static Future<List<Map<String, dynamic>>> getCourseFiles(
    String courseCode,
  ) async {
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

  /// 📚 Get course materials from course_materials table
  static Future<List<Map<String, dynamic>>> getCourseMaterials(
    String courseCode,
  ) async {
    try {
      final response = await _client
          .from('course_materials')
          .select()
          .eq('course_code', courseCode)
          .order('created_at', ascending: false);

      print("📚 Found ${response.length} materials for course $courseCode");
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("❌ Error fetching course materials: $e");
      return [];
    }
  }

  /// 📊 Get student marks
  static Future<List<Map<String, dynamic>>> getStudentMarks(
    String studentId,
  ) async {
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
  static Future<List<Map<String, dynamic>>> getAttendance(
    String studentId,
  ) async {
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
    String courseCode,
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
  static Future<List<Map<String, dynamic>>> getTeacherCourses(
    String teacherId,
  ) async {
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
  static Future<List<Map<String, dynamic>>> getEnrolledStudents(
    String courseCode,
  ) async {
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
  static Future<List<Map<String, dynamic>>> debugEnrollments(
    String courseCode,
  ) async {
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

  /// 👥 Get students by course (using enrollments table)
  static Future<List<Map<String, dynamic>>> getStudentsByCourse(
    String courseCode,
  ) async {
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

      print(
        'Found ${studentIds.length} students enrolled in course: $courseCode',
      );

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
  static Future<void> saveAttendance(
    List<Map<String, dynamic>> attendanceRecords,
  ) async {
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
    String date,
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
  static Future<List<Map<String, dynamic>>> getCourseMarks(
    String courseCode,
  ) async {
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
      print('✅ Marks saved successfully');
    } catch (e) {
      print('❌ Error saving marks: $e');
      rethrow;
    }
  }

  /// ==================== FILE UPLOAD METHODS ====================

  /// 📤 Upload file to Supabase Storage (for mobile)
  static Future<String?> uploadFile({
    required String filePath,
    required String fileName,
    required String courseCode,
  }) async {
    try {
      print('📤 Uploading file: $fileName to course: $courseCode');

      final file = File(filePath);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final cleanFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9\.]'), '_');
      final storagePath = '$courseCode/${timestamp}_$cleanFileName';

      // Upload to storage bucket
      await _client.storage.from('course-materials').upload(storagePath, file);

      // Get public URL
      final publicUrl = _client.storage
          .from('course-materials')
          .getPublicUrl(storagePath);

      print('✅ File uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Error uploading file: $e');
      return null;
    }
  }

  /// 📤 Upload file to Supabase Storage (for web - uses bytes)
  static Future<String?> uploadFileWeb({
    required Uint8List fileBytes,
    required String fileName,
    required String courseCode,
  }) async {
    try {
      print('📤 Uploading file (web): $fileName to course: $courseCode');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      // Clean filename - remove special characters
      final cleanFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9\.]'), '_');
      final storagePath = '$courseCode/${timestamp}_$cleanFileName';

      print('📁 Storage path: $storagePath');

      // Determine content type
      String contentType = 'application/octet-stream';
      if (fileName.toLowerCase().endsWith('.pdf')) {
        contentType = 'application/pdf';
      } else if (fileName.toLowerCase().endsWith('.jpg') ||
          fileName.toLowerCase().endsWith('.jpeg')) {
        contentType = 'image/jpeg';
      } else if (fileName.toLowerCase().endsWith('.png')) {
        contentType = 'image/png';
      }

      // Upload bytes to storage bucket
      await _client.storage
          .from('course-materials')
          .uploadBinary(
            storagePath,
            fileBytes,
            fileOptions: FileOptions(contentType: contentType),
          );

      print('✅ File uploaded to storage successfully');

      // Get public URL
      final publicUrl = _client.storage
          .from('course-materials')
          .getPublicUrl(storagePath);

      print('✅ Public URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Error uploading file (web): $e');
      return null;
    }
  }

  /// 📤 Upload course material info to database
  static Future<void> uploadCourseMaterial(
    Map<String, dynamic> material,
  ) async {
    try {
      // Add created_at timestamp if not present
      if (!material.containsKey('created_at')) {
        material['created_at'] = DateTime.now().toIso8601String();
      }

      // Remove published_at if it exists (to avoid schema error)
      material.remove('published_at');

      await _client.from('course_materials').insert(material);
      print('✅ Material info saved to database: ${material['title']}');
    } catch (e) {
      print('❌ Error saving material info: $e');
      rethrow;
    }
  }

  /// 📥 Get all materials for a course (alias for getCourseMaterials)
  static Future<List<Map<String, dynamic>>> getCourseMaterialsWithFiles(
    String courseCode,
  ) async {
    return await getCourseMaterials(courseCode);
  }

  /// 🗑️ Delete a material (file and database record)
  static Future<void> deleteMaterial(int materialId, {String? fileUrl}) async {
    try {
      // Delete from database first
      await _client.from('course_materials').delete().eq('id', materialId);

      // If there's a file URL, try to delete from storage
      if (fileUrl != null && fileUrl.isNotEmpty) {
        // Extract path from URL
        final uri = Uri.parse(fileUrl);
        final pathSegments = uri.pathSegments;
        if (pathSegments.length >= 2) {
          final courseCode = pathSegments[pathSegments.length - 2];
          final fileName = pathSegments.last;
          final storagePath = '$courseCode/$fileName';

          await _client.storage.from('course-materials').remove([storagePath]);
          print('✅ File deleted from storage: $storagePath');
        }
      }

      print('✅ Material deleted successfully');
    } catch (e) {
      print('❌ Error deleting material: $e');
      rethrow;
    }
  }

  /// 📋 Get list of files in storage for a course
  static Future<List<String>> getCourseStorageFiles(String courseCode) async {
    try {
      final response = await _client.storage
          .from('course-materials')
          .list(path: courseCode);

      return response.map((file) => file.name).toList();
    } catch (e) {
      print('Error listing course files: $e');
      return [];
    }
  }

  /// ==================== TODO FUNCTIONS ====================

  /// 📝 Get todos for a student
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

  /// ➕ Add a new todo
  static Future<void> addTodo(Map<String, dynamic> todo) async {
    try {
      await _client.from('student_todos').insert(todo);
      print("✅ Todo added successfully");
    } catch (e) {
      print("❌ Error adding todo: $e");
    }
  }

  /// ✏️ Update a todo
  static Future<void> updateTodo(int id, Map<String, dynamic> updates) async {
    try {
      await _client.from('student_todos').update(updates).eq('id', id);
      print("✅ Todo updated successfully");
    } catch (e) {
      print("❌ Error updating todo: $e");
    }
  }

  /// ✅ Mark todo as completed
  static Future<void> markTodoCompleted(int id, bool isCompleted) async {
    try {
      await _client
          .from('student_todos')
          .update({'is_completed': isCompleted})
          .eq('id', id);
      print("✅ Todo status updated");
    } catch (e) {
      print("❌ Error updating todo status: $e");
    }
  }

  /// 🗑️ Delete a todo
  static Future<void> deleteTodo(int id) async {
    try {
      await _client.from('student_todos').delete().eq('id', id);
      print("✅ Todo deleted successfully");
    } catch (e) {
      print("❌ Error deleting todo: $e");
    }
  }
}
