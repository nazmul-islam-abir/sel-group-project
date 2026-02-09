import 'package:supabase_flutter/supabase_flutter.dart';

/// This file handles ALL Supabase related work
/// UI pages should NEVER talk to Supabase directly
class SupabaseConnector {
  // Shortcut for Supabase client
  static final SupabaseClient _client =
      Supabase.instance.client;

  ///  Fetch single student data from "students" table
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
static Future<List<Map<String, dynamic>>> getEnrolledCourses(
    String studentId) async {
  // Query enrolled_courses table where student_id matches
  final response = await _client
      .from('enrolled_courses')
      .select()
      .eq('student_id', studentId);

  // Convert response to List<Map>
  return List<Map<String, dynamic>>.from(response);
}

static Future<List<Map<String, dynamic>>> getCourseFiles(String courseCode) async {
    try {
      final response = await _client
          .from('course_files')  // Your table name
          .select()              // Select all columns
          .eq('course_code', courseCode);  // Filter by course code
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error getting files: $e");
      return [];  // Return empty list if error
    }
}

}
