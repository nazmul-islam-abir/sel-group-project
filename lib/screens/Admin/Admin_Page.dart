// Add Student Form

import 'package:flutter/material.dart';
import '../../connectors/supabase_connector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyAdmin extends StatefulWidget {
  const MyAdmin({super.key});

  @override
  State<MyAdmin> createState() => _MyAdminState();
}

class _MyAdminState extends State<MyAdmin> {
  // ADMIN DATA LISTS 
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> teachers = [];
  List<Map<String, dynamic>> courses = [];
  List<Map<String, dynamic>> semesters = [];
  List<Map<String, dynamic>> enrolledCourses = [];
  
  //  UI STATE 
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  String activeTab = 'students';
  

  bool showAddStudentForm = false;
  
  // Student form controllers
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _studentEmailController = TextEditingController();
  final TextEditingController _studentDepartmentController = TextEditingController();
  
  // Search controller
  final TextEditingController _searchController = TextEditingController();

  // Supabase client
  static final SupabaseClient _client = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    loadAllAdminData();
  }

  ///  Load ALL admin data
  Future<void> loadAllAdminData() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
        students.clear();
      });

      // Load students
      try {
        final response = await _client.from('students').select();
        students = List<Map<String, dynamic>>.from(response);
        print("Loaded ${students.length} students");
      } catch (e) {
        print("Error loading students: $e");
        students = [];
      }
      
      // Also load other tables but keep them empty for now
      try {
        final response = await _client.from('teachers').select();
        teachers = List<Map<String, dynamic>>.from(response);
      } catch (e) {
        teachers = [];
      }
      
      try {
        final response = await _client.from('courses').select();
        courses = List<Map<String, dynamic>>.from(response);
      } catch (e) {
        courses = [];
      }
      
      try {
        final response = await _client.from('semesters').select();
        semesters = List<Map<String, dynamic>>.from(response);
      } catch (e) {
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

  /// Add new student to "students" table
  Future<void> addStudent() async {
    // Validate required fields
    if (_studentNameController.text.isEmpty) {
      _showSnackBar('Name is required', Colors.orange);
      return;
    }
    if (_studentIdController.text.isEmpty) {
      _showSnackBar('Student ID is required', Colors.orange);
      return;
    }

    try {
      final studentData = {
        'student_id': _studentIdController.text,
        'name': _studentNameController.text,
        'email': _studentEmailController.text,
        'department': _studentDepartmentController.text,
        'semester': 'Spring2025', // Default semester value
      };
      
      print("Inserting student: $studentData");
      await _client.from('students').insert(studentData);
      print("Student added successfully");
      
      // Reload data
      await loadAllAdminData();
      
      // Clear controllers
      _studentNameController.clear();
      _studentEmailController.clear();
      _studentDepartmentController.clear();
      _studentIdController.clear();
      
      setState(() {
        showAddStudentForm = false;
      });
      
      _showSnackBar('Student added successfully!', Colors.green);
    } catch (error) {
      print("Error adding student: $error");
      _showSnackBar('Error: ${error.toString()}', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    if (isLoading) return Container();
    
    // Only show FAB for students tab at this stage
    if (activeTab != 'students') return Container();
    
    return FloatingActionButton.extended(
      onPressed: () {
        setState(() {
          showAddStudentForm = true;
        });
      },
      backgroundColor: Colors.blue,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'Add Student',
        style: TextStyle(color: Colors.white),
      ),
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
            Text(
              'Loading students...',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
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
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: loadAllAdminData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadAllAdminData,
      child: Column(
        children: [
          // ADMIN HEADER 
          _buildAdminHeader(),

          // SEARCH BAR 
          _buildSearchBar(),

          //  STATS CARDS 
          _buildStatsCards(),

          // TAB BAR 
          _buildTabBar(),

          // CONTENT
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildActiveContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 30, left: 20, right: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              size: 50,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Admin Portal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Student Management',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search students by name or ID...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
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
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.person,
            value: students.length.toString(),
            label: 'Students',
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.person_outline,
            value: teachers.length.toString(),
            label: 'Teachers',
            color: Colors.green,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.book,
            value: courses.length.toString(),
            label: 'Courses',
            color: Colors.orange,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.school,
            value: enrolledCourses.length.toString(),
            label: 'Enrollments',
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTab('students', Icons.people),
          _buildTab('teachers', Icons.person_outline),
          _buildTab('courses', Icons.book),
          _buildTab('semesters', Icons.calendar_month),
          _buildTab('enrollments', Icons.how_to_reg),
        ],
      ),
    );
  }

  Widget _buildTab(String tabName, IconData icon) {
    final isActive = activeTab == tabName;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            activeTab = tabName;
            showAddStudentForm = false; // Hide form when switching tabs
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue.shade50 : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? Colors.blue : Colors.grey.shade500,
              ),
              const SizedBox(height: 4),
              Text(
                tabName[0].toUpperCase() + tabName.substring(1),
                style: TextStyle(
                  fontSize: 11,
                  color: isActive ? Colors.blue : Colors.grey.shade600,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveContent() {
    // Show add student form if visible
    if (showAddStudentForm) {
      return _buildAddStudentForm();
    }
    
    // Show appropriate list based on active tab
    switch (activeTab) {
      case 'students':
        return _buildStudentsList();
      case 'teachers':
        return _buildComingSoon('Teachers');
      case 'courses':
        return _buildComingSoon('Courses');
      case 'semesters':
        return _buildComingSoon('Semesters');
      case 'enrollments':
        return _buildComingSoon('Enrollments');
      default:
        return _buildStudentsList();
    }
  }

  // STUDENT FORM 
  Widget _buildAddStudentForm() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add New Student',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    showAddStudentForm = false;
                    // Clear controllers when closing
                    _studentIdController.clear();
                    _studentNameController.clear();
                    _studentEmailController.clear();
                    _studentDepartmentController.clear();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Student ID Field
          TextField(
            controller: _studentIdController,
            decoration: const InputDecoration(
              labelText: 'Student ID',
              hintText: 'e.g. 0222310005101085',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.badge),
            ),
          ),
          const SizedBox(height: 15),
          
          // Student Name Field
          TextField(
            controller: _studentNameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              hintText: 'e.g. John Doe',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 15),
          
          // Email Field
          TextField(
            controller: _studentEmailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'student@example.com',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 15),
          
          // Department Field
          TextField(
            controller: _studentDepartmentController,
            decoration: const InputDecoration(
              labelText: 'Department',
              hintText: 'e.g. CSE',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.business),
            ),
          ),
          const SizedBox(height: 20),
          
          // Semester Info - Display only (auto-set to Spring2025)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Semester will be set to Spring2025 automatically',
                    style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Buttons
          Row(
            children: [
              // Cancel Button
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      showAddStudentForm = false;
                      // Clear controllers
                      _studentIdController.clear();
                      _studentNameController.clear();
                      _studentEmailController.clear();
                      _studentDepartmentController.clear();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 15),
              
              // Add Student Button
              Expanded(
                child: ElevatedButton(
                  onPressed: addStudent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Add Student',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //STUDENTS LIST
  Widget _buildStudentsList() {
    if (students.isEmpty) {
      return _buildEmptySection(
        icon: Icons.people,
        title: 'No Students Found',
        subtitle: 'Click the + button to add your first student',
      );
    }

    // Filter students based on search
    var filteredStudents = students;
    if (_searchController.text.isNotEmpty) {
      filteredStudents = students.where((student) {
        final searchTerm = _searchController.text.toLowerCase();
        return (student['name']?.toString().toLowerCase().contains(searchTerm) ?? false) ||
               (student['student_id']?.toString().toLowerCase().contains(searchTerm) ?? false) ||
               (student['department']?.toString().toLowerCase().contains(searchTerm) ?? false);
      }).toList();
    }

    if (filteredStudents.isEmpty) {
      return _buildEmptySection(
        icon: Icons.search_off,
        title: 'No Results Found',
        subtitle: 'Try searching with different keywords',
      );
    }

    return Column(
      children: [
        const SizedBox(height: 10),
        ...filteredStudents.map((student) => _buildStudentCard(student)).toList(),
        const SizedBox(height: 20),
        // Show total count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Showing ${filteredStudents.length} of ${students.length} students',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.blue,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          
          // Student Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${student['student_id'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                if (student['email'] != null && student['email'].toString().isNotEmpty)
                  Text(
                    student['email'],
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                if (student['department'] != null && student['department'].toString().isNotEmpty)
                  Text(
                    student['department'],
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                Text(
                  'Semester: ${student['semester'] ?? 'Spring2025'}',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                ),
              ],
            ),
          ),
          
          // Semester badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              student['semester'] ?? '2025',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildComingSoon(String feature) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.build_circle,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            '$feature Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Coming Soon!',
            style: TextStyle(
              fontSize: 18,
              color: Colors.blue.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'This feature is under development.\nPlease check back later.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildEmptySection({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 15),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _studentIdController.dispose();
    _studentNameController.dispose();
    _studentEmailController.dispose();
    _studentDepartmentController.dispose();
    super.dispose();
  }
}