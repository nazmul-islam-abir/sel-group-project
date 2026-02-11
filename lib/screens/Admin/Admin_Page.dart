// admin_page.dart - Part 6: Students List View
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
  
  final TextEditingController _searchController = TextEditingController();
  static final SupabaseClient _client = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    loadAllAdminData();
  }

  Future<void> loadAllAdminData() async {
    try {
      setState(() { isLoading = true; hasError = false; });

      final studentsRes = await _client.from('students').select();
      students = List<Map<String, dynamic>>.from(studentsRes);
      
      final teachersRes = await _client.from('teachers').select();
      teachers = List<Map<String, dynamic>>.from(teachersRes);
      
      final coursesRes = await _client.from('courses').select();
      courses = List<Map<String, dynamic>>.from(coursesRes);
      
      final semestersRes = await _client.from('semesters').select();
      semesters = List<Map<String, dynamic>>.from(semestersRes);

      setState(() => isLoading = false);
    } catch (error) {
      setState(() { isLoading = false; hasError = true; errorMessage = error.toString(); });
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
    if (isLoading) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const CircularProgressIndicator(), const SizedBox(height: 20), Text('Loading...', style: TextStyle(fontSize: 16, color: Colors.grey.shade600))]));
    if (hasError) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.error_outline, size: 80, color: Colors.red), const SizedBox(height: 20), const Text('Error loading data'), ElevatedButton.icon(onPressed: loadAllAdminData, icon: const Icon(Icons.refresh), label: const Text('Try Again'))]));

    return RefreshIndicator(
      onRefresh: loadAllAdminData,
      child: Column(
        children: [
          _buildAdminHeader(),
          _buildSearchBar(),
          _buildStatsCards(),
          _buildTabBar(),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: _buildActiveContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveContent() {
    switch (activeTab) {
      case 'students':
        return _buildStudentsList();
      default:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Text('${_getTabTitle()} section coming soon', style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ),
        );
    }
  }

  Widget _buildStudentsList() {
    if (students.isEmpty) {
      return _buildEmptySection(
        icon: Icons.people,
        title: 'No Students Found',
        subtitle: 'Add your first student',
      );
    }

    var filteredStudents = students;
    if (_searchController.text.isNotEmpty) {
      filteredStudents = students.where((student) {
        final searchTerm = _searchController.text.toLowerCase();
        return (student['name']?.toString().toLowerCase().contains(searchTerm) ?? false) ||
               (student['student_id']?.toString().toLowerCase().contains(searchTerm) ?? false);
      }).toList();
    }

    return Column(
      children: [
        const SizedBox(height: 10),
        ...filteredStudents.map((student) => _buildStudentCard(student)).toList(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
            child: const Icon(Icons.person, color: Colors.blue, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('ID: ${student['student_id'] ?? 'N/A'}', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                if (student['email'] != null)
                  Text(student['email'], style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ],
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

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search ${activeTab}...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: Colors.grey), onPressed: () { _searchController.clear(); setState(() {}); }) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        _buildStatCard(icon: Icons.person, value: students.length.toString(), label: 'Students', color: Colors.blue),
        const SizedBox(width: 12),
        _buildStatCard(icon: Icons.person_outline, value: teachers.length.toString(), label: 'Teachers', color: Colors.green),
        const SizedBox(width: 12),
        _buildStatCard(icon: Icons.book, value: courses.length.toString(), label: 'Courses', color: Colors.orange),
        const SizedBox(width: 12),
        _buildStatCard(icon: Icons.school, value: enrolledCourses.length.toString(), label: 'Enrollments', color: Colors.purple),
      ]),
    );
  }

  Widget _buildStatCard({required IconData icon, required String value, required String label, required Color color}) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3))]),
      child: Column(children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ]),
    ));
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
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
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

  Widget _buildEmptySection({required IconData icon, required String title, required String subtitle}) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(children: [
        Icon(icon, size: 60, color: Colors.grey.shade400),
        const SizedBox(height: 15),
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
        const SizedBox(height: 5),
        Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500)),
      ]),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}