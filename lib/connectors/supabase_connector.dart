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
}
