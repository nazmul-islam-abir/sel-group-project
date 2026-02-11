// admin_page.dart - Part 4: Data Lists & Supabase Integration
import 'package:flutter/material.dart';
import '../../connectors/supabase_connector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyAdmin extends StatefulWidget {
  const MyAdmin({super.key});

  @override
  State<MyAdmin> createState() => _MyAdminState();
}

class _MyAdminState extends State<MyAdmin> {
  // ================= ADMIN DATA LISTS =================
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> teachers = [];
  List<Map<String, dynamic>> courses = [];
  List<Map<String, dynamic>> semesters = [];
  List<Map<String, dynamic>> enrolledCourses = [];
  
  // ================= UI STATE =================
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  String activeTab = 'students';
  
  static final SupabaseClient _client = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    loadAllAdminData();
  }

  Future<void> loadAllAdminData() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      // Load data from Supabase
      try {
        final response = await _client.from('students').select();
        students = List<Map<String, dynamic>>.from(response);
      } catch (e) {
        print("Error loading students: $e");
        students = [];
      }

      try {
        final response = await _client.from('teachers').select();
        teachers = List<Map<String, dynamic>>.from(response);
      } catch (e) {
        print("Error loading teachers: $e");
        teachers = [];
      }

      try {
        final response = await _client.from('courses').select();
        courses = List<Map<String, dynamic>>.from(response);
      } catch (e) {
        print("Error loading courses: $e");
        courses = [];
      }

      try {
        final response = await _client.from('semesters').select();
        semesters = List<Map<String, dynamic>>.from(response);
      } catch (e) {
        print("Error loading semesters: $e");
        semesters = [];
      }

      setState(() => isLoading = false);
    } catch (error) {
      print("Error loading admin data: $error");
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text('Loading admin dashboard...', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text('Something went wrong', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(onPressed: loadAllAdminData, icon: const Icon(Icons.refresh), label: const Text('Try Again')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadAllAdminData,
      child: Column(
        children: [
          _buildAdminHeader(),
          _buildTabBar(),
          Expanded(
            child: Center(
              child: Text('${_getTabTitle()} loaded: ${_getDataCount()}'),
            ),
          ),
        ],
      ),
    );
  }

  String _getTabTitle() {
    switch (activeTab) {
      case 'students': return 'Students';
      case 'teachers': return 'Teachers';
      case 'courses': return 'Courses';
      case 'semesters': return 'Semesters';
      case 'enrollments': return 'Enrollments';
      default: return 'Items';
    }
  }

  String _getDataCount() {
    switch (activeTab) {
      case 'students': return students.length.toString();
      case 'teachers': return teachers.length.toString();
      case 'courses': return courses.length.toString();
      case 'semesters': return semesters.length.toString();
      case 'enrollments': return enrolledCourses.length.toString();
      default: return '0';
    }
  }

  Widget _buildAdminHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 30, left: 20, right: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade800, Colors.blue.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(children: [
        Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: Colors.white, width: 3)), child: const Icon(Icons.admin_panel_settings, size: 50, color: Colors.blue)),
        const SizedBox(height: 15),
        const Text('Admin Portal', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: const Text('System Management Dashboard', style: TextStyle(color: Colors.white, fontSize: 14))),
      ]),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3))]),
      child: Row(children: [
        _buildTab('students', Icons.people),
        _buildTab('teachers', Icons.person_outline),
        _buildTab('courses', Icons.book),
        _buildTab('semesters', Icons.calendar_month),
        _buildTab('enrollments', Icons.how_to_reg),
      ]),
    );
  }

  Widget _buildTab(String tabName, IconData icon) {
    final isActive = activeTab == tabName;
    return Expanded(child: InkWell(
      onTap: () => setState(() => activeTab = tabName),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: isActive ? Colors.blue.shade50 : Colors.transparent, borderRadius: BorderRadius.circular(12)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 20, color: isActive ? Colors.blue : Colors.grey.shade500),
          const SizedBox(height: 4),
          Text(tabName[0].toUpperCase() + tabName.substring(1), style: TextStyle(fontSize: 11, color: isActive ? Colors.blue : Colors.grey.shade600, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
        ]),
      ),
    ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}