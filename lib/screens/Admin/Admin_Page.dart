// Complete CRUD (up to sem) - Updated with requested changes
import 'package:flutter/material.dart';
import '../../connectors/supabase_connector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../login_page.dart';

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

  //UI STATE
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  String activeTab = 'students';

  //FORM VISIBILITY
  bool showAddStudentForm = false;
  bool showAddTeacherForm = false;
  bool showAddCourseForm = false;

  //STUDENT CONTROLLERS
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _studentEmailController = TextEditingController();
  final TextEditingController _studentDepartmentController =
      TextEditingController();
  final TextEditingController _studentSemesterController =
      TextEditingController();

  //TEACHER CONTROLLERS - UPDATED with new fields
  final TextEditingController _teacherIdController = TextEditingController();
  final TextEditingController _teacherNameController = TextEditingController();
  final TextEditingController _teacherEmailController = TextEditingController();
  final TextEditingController _teacherDepartmentController =
      TextEditingController();
  final TextEditingController _teacherDesignationController =
      TextEditingController();
  final TextEditingController _teacherPhoneController = TextEditingController();

  //COURSE CONTROLLERS
  final TextEditingController _courseCodeController = TextEditingController();
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _courseCreditsController =
      TextEditingController();

  //SEARCH CONTROLLER
  final TextEditingController _searchController = TextEditingController();

  // Supabase client
  static final SupabaseClient _client = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    loadAllAdminData();
  }

  /// Load ALL admin data
  Future<void> loadAllAdminData() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
        students.clear();
        teachers.clear();
        courses.clear();
      });

      // Load students
      try {
        final response = await _client.from('students').select();
        students = List<Map<String, dynamic>>.from(response);
      } catch (e) {
        print("Error loading students: $e");
      }

      // Load teachers
      try {
        final response = await _client.from('teachers').select();
        teachers = List<Map<String, dynamic>>.from(response);
      } catch (e) {
        print("Error loading teachers: $e");
      }

      // Load courses
      try {
        final response = await _client.from('courses').select();
        courses = List<Map<String, dynamic>>.from(response);
      } catch (e) {
        print("Error loading courses: $e");
      }

      setState(() => isLoading = false);
    } catch (error) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = error.toString();
      });
    }
  }

  //STUDENT OPERATIONS
  Future<void> addStudent() async {
    if (_studentNameController.text.isEmpty ||
        _studentIdController.text.isEmpty) {
      _showSnackBar('Name and ID are required', Colors.orange);
      return;
    }

    try {
      await _client.from('students').insert({
        'student_id': _studentIdController.text,
        'name': _studentNameController.text,
        'email': _studentEmailController.text,
        'department': _studentDepartmentController.text,
        'semester': _studentSemesterController.text.isEmpty
            ? 'Spring2025'
            : _studentSemesterController.text,
      });
      await loadAllAdminData();
      _clearStudentControllers();
      setState(() => showAddStudentForm = false);
      _showSnackBar('Student added successfully', Colors.green);
    } catch (error) {
      _showSnackBar('Error: $error', Colors.red);
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      await _client.from('students').delete().eq('student_id', id);
      await loadAllAdminData();
      _showSnackBar('Student deleted successfully', Colors.green);
    } catch (error) {
      _showSnackBar('Error deleting student: $error', Colors.red);
    }
  }

  //TEACHER OPERATIONS - UPDATED with new fields
  Future<void> addTeacher() async {
    if (_teacherNameController.text.isEmpty ||
        _teacherIdController.text.isEmpty) {
      _showSnackBar('Name and ID are required', Colors.orange);
      return;
    }

    try {
      await _client.from('teachers').insert({
        'teacher_id': _teacherIdController.text,
        'name': _teacherNameController.text,
        'email': _teacherEmailController.text,
        'department': _teacherDepartmentController.text,
        'designation': _teacherDesignationController.text,
        'phone': _teacherPhoneController.text,
      });
      await loadAllAdminData();
      _clearTeacherControllers();
      setState(() => showAddTeacherForm = false);
      _showSnackBar('Teacher added successfully', Colors.green);
    } catch (error) {
      _showSnackBar('Error: $error', Colors.red);
    }
  }

  Future<void> deleteTeacher(String id) async {
    try {
      await _client.from('teachers').delete().eq('teacher_id', id);
      await loadAllAdminData();
      _showSnackBar('Teacher deleted successfully', Colors.green);
    } catch (error) {
      _showSnackBar('Error deleting teacher: $error', Colors.red);
    }
  }

  //COURSE OPERATIONS
  Future<void> addCourse() async {
    if (_courseCodeController.text.isEmpty ||
        _courseNameController.text.isEmpty) {
      _showSnackBar('Course code and name are required', Colors.orange);
      return;
    }

    try {
      await _client.from('courses').insert({
        'course_code': _courseCodeController.text,
        'course_name': _courseNameController.text,
        'credits': int.tryParse(_courseCreditsController.text) ?? 3,
      });
      await loadAllAdminData();
      _clearCourseControllers();
      setState(() => showAddCourseForm = false);
      _showSnackBar('Course added successfully', Colors.green);
    } catch (error) {
      _showSnackBar('Error: $error', Colors.red);
    }
  }

  Future<void> deleteCourse(String code) async {
    try {
      await _client.from('courses').delete().eq('course_code', code);
      await loadAllAdminData();
      _showSnackBar('Course deleted successfully', Colors.green);
    } catch (error) {
      _showSnackBar('Error deleting course: $error', Colors.red);
    }
  }

  // CLEAR CONTROLLERS
  void _clearStudentControllers() {
    _studentNameController.clear();
    _studentEmailController.clear();
    _studentDepartmentController.clear();
    _studentIdController.clear();
    _studentSemesterController.clear();
  }

  void _clearTeacherControllers() {
    _teacherNameController.clear();
    _teacherEmailController.clear();
    _teacherDepartmentController.clear();
    _teacherIdController.clear();
    _teacherDesignationController.clear();
    _teacherPhoneController.clear();
  }

  void _clearCourseControllers() {
    _courseCodeController.clear();
    _courseNameController.clear();
    _courseCreditsController.clear();
  }

  //DELETE CONFIRMATION
  void _showDeleteConfirmation(String type, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $type'),
        content: Text(
          'Are you sure you want to delete this $type? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              switch (type) {
                case 'student':
                  deleteStudent(id);
                  break;
                case 'teacher':
                  deleteTeacher(id);
                  break;
                case 'course':
                  deleteCourse(id);
                  break;
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade100,
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    if (isLoading) return Container();

    String label = '';
    Color color = Colors.blue;

    switch (activeTab) {
      case 'students':
        label = 'Add Student';
        color = Colors.blue;
        break;
      case 'teachers':
        label = 'Add Teacher';
        color = Colors.green;
        break;
      case 'courses':
        label = 'Add Course';
        color = Colors.orange;
        break;
      default:
        return Container();
    }

    return FloatingActionButton.extended(
      onPressed: () {
        switch (activeTab) {
          case 'students':
            setState(() => showAddStudentForm = true);
            break;
          case 'teachers':
            setState(() => showAddTeacherForm = true);
            break;
          case 'courses':
            setState(() => showAddCourseForm = true);
            break;
        }
      },
      backgroundColor: color,
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
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
              'Loading...',
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
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
          _buildAdminHeader(),
          _buildSearchBar(),
          _buildStatsCards(),
          _buildTabBar(),
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

  void _logout() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _clearAdminSession(); // Clear any user data/session if needed
              // Navigate to login page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // Clear admin session data
  void _clearAdminSession() async {
    // Clear any stored admin data
    // For example:
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.clear();

    // If using Supabase Auth
    // await Supabase.instance.client.auth.signOut();

    print('Admin session cleared');
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
              'Management Dashboard',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    if (activeTab != 'students') return const SizedBox.shrink();

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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
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
            Icons.person,
            students.length.toString(),
            'Students',
            Colors.blue,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            Icons.person_outline,
            teachers.length.toString(),
            'Teachers',
            Colors.green,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            Icons.book,
            courses.length.toString(),
            'Courses',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
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
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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
            showAddStudentForm = false;
            showAddTeacherForm = false;
            showAddCourseForm = false;
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
    // Show forms
    if (showAddStudentForm) return _buildAddStudentForm();
    if (showAddTeacherForm) return _buildAddTeacherForm();
    if (showAddCourseForm) return _buildAddCourseForm();

    // Show lists
    switch (activeTab) {
      case 'students':
        return _buildStudentsList();
      case 'teachers':
        return _buildTeachersList();
      case 'courses':
        return _buildCoursesList();
      default:
        return _buildStudentsList();
    }
  }

  //ADD FORMS
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add New Student',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                  showAddStudentForm = false;
                  _clearStudentControllers();
                }),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _studentIdController,
            decoration: const InputDecoration(
              labelText: 'Student ID *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.badge),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _studentNameController,
            decoration: const InputDecoration(
              labelText: 'Full Name *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _studentEmailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _studentDepartmentController,
            decoration: const InputDecoration(
              labelText: 'Department',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.business),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _studentSemesterController,
            decoration: const InputDecoration(
              labelText: 'Semester (e.g., Spring2025)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_month),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      showAddStudentForm = false;
                      _clearStudentControllers();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  onPressed: addStudent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'Add Student',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddTeacherForm() {
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add New Teacher',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() {
                    showAddTeacherForm = false;
                    _clearTeacherControllers();
                  }),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _teacherIdController,
              decoration: const InputDecoration(
                labelText: 'Teacher ID *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _teacherNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _teacherEmailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _teacherDepartmentController,
              decoration: const InputDecoration(
                labelText: 'Department',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _teacherDesignationController,
              decoration: const InputDecoration(
                labelText: 'Designation',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _teacherPhoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        showAddTeacherForm = false;
                        _clearTeacherControllers();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: addTeacher,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'Add Teacher',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCourseForm() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add New Course',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                  showAddCourseForm = false;
                  _clearCourseControllers();
                }),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _courseCodeController,
            decoration: const InputDecoration(
              labelText: 'Course Code *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.code),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _courseNameController,
            decoration: const InputDecoration(
              labelText: 'Course Name *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.book),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _courseCreditsController,
            decoration: const InputDecoration(
              labelText: 'Credits',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.grade),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      showAddCourseForm = false;
                      _clearCourseControllers();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  onPressed: addCourse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'Add Course',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // LIST BUILDERS
  List<Map<String, dynamic>> _filterList(
    List<Map<String, dynamic>> list,
    List<String> fields,
  ) {
    if (_searchController.text.isEmpty || activeTab != 'students') return list;
    final term = _searchController.text.toLowerCase();
    return list
        .where(
          (item) => fields.any(
            (field) =>
                item[field]?.toString().toLowerCase().contains(term) ?? false,
          ),
        )
        .toList();
  }

  Widget _buildStudentsList() {
    if (students.isEmpty)
      return _buildEmptySection(
        Icons.people,
        'No Students Found',
        'Click the + button to add your first student',
      );
    final filtered = _filterList(students, [
      'name',
      'student_id',
      'department',
      'email',
    ]);
    if (filtered.isEmpty)
      return _buildEmptySection(
        Icons.search_off,
        'No Results Found',
        'Try searching with different keywords',
      );

    return Column(
      children: [
        const SizedBox(height: 10),
        ...filtered.map((student) => _buildStudentCard(student)).toList(),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Showing ${filtered.length} of ${students.length} students',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ),
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
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.blue, size: 30),
          ),
          const SizedBox(width: 15),
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
                if (student['email'] != null &&
                    student['email'].toString().isNotEmpty)
                  Text(
                    student['email'],
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                if (student['department'] != null &&
                    student['department'].toString().isNotEmpty)
                  Text(
                    'Dept: ${student['department']}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                Text(
                  'Semester: ${student['semester'] ?? 'Spring2025'}',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (_) =>
                _showDeleteConfirmation('student', student['student_id']),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeachersList() {
    if (teachers.isEmpty)
      return _buildEmptySection(
        Icons.person_outline,
        'No Teachers Found',
        'Click the + button to add your first teacher',
      );

    return Column(
      children: [
        const SizedBox(height: 10),
        ...teachers.map((teacher) => _buildTeacherCard(teacher)).toList(),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Total: ${teachers.length} teachers',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildTeacherCard(Map<String, dynamic> teacher) {
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
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.green,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher['name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${teacher['teacher_id'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                if (teacher['designation'] != null &&
                    teacher['designation'].toString().isNotEmpty)
                  Text(
                    teacher['designation'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (teacher['department'] != null &&
                    teacher['department'].toString().isNotEmpty)
                  Text(
                    'Dept: ${teacher['department']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                if (teacher['email'] != null &&
                    teacher['email'].toString().isNotEmpty)
                  Text(
                    teacher['email'],
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                if (teacher['phone'] != null &&
                    teacher['phone'].toString().isNotEmpty)
                  Text(
                    '📞 ${teacher['phone']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                    ),
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (_) =>
                _showDeleteConfirmation('teacher', teacher['teacher_id']),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesList() {
    if (courses.isEmpty)
      return _buildEmptySection(
        Icons.book,
        'No Courses Found',
        'Click the + button to add your first course',
      );

    return Column(
      children: [
        const SizedBox(height: 10),
        ...courses.map((course) => _buildCourseCard(course)).toList(),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Total: ${courses.length} courses',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
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
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.book, color: Colors.orange, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['course_code'] ?? 'No Code',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  course['course_name'] ?? 'Unknown',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                Text(
                  'Credits: ${course['credits'] ?? 3}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (_) =>
                _showDeleteConfirmation('course', course['course_code']),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection(IconData icon, String title, String subtitle) {
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
            style: TextStyle(color: Colors.grey.shade500),
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
    _studentSemesterController.dispose();
    _teacherIdController.dispose();
    _teacherNameController.dispose();
    _teacherEmailController.dispose();
    _teacherDepartmentController.dispose();
    _teacherDesignationController.dispose();
    _teacherPhoneController.dispose();
    _courseCodeController.dispose();
    _courseNameController.dispose();
    _courseCreditsController.dispose();
    super.dispose();
  }
}
