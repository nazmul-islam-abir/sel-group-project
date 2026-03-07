import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/screens/student/navigation_page.dart';
import 'package:myapp/screens/teacher/teacher_navigation_page.dart';
import 'package:myapp/screens/Admin/Admin_Page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  // 0 = Student, 1 = Teacher, 2 = Admin
  int _selectedRole = 0;
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Controllers
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static final SupabaseClient _client = Supabase.instance.client;

  final List<_RoleConfig> _roles = [
    _RoleConfig(
      label: 'Student Portal',
      icon: Icons.person_3_rounded,
      color: Colors.blue,
      gradient: [Color(0xFF1565C0), Color(0xFF42A5F5)],
    ),
    _RoleConfig(
      label: 'Teacher Portal',
      icon: Icons.school,
      color: Colors.green,
      gradient: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
    ),
    _RoleConfig(
      label: 'Admin Portal',
      icon: Icons.admin_panel_settings,
      color: Colors.deepOrange,
      gradient: [Color(0xFFBF360C), Color(0xFFFF7043)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _idController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _switchRole(int index) {
    if (index == _selectedRole) return;
    _animationController.reverse().then((_) {
      setState(() {
        _selectedRole = index;
        _clearControllers();
      });
      _animationController.forward();
    });
  }

  void _clearControllers() {
    _idController.clear();
    _emailController.clear();
    _usernameController.clear();
    _passwordController.clear();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      switch (_selectedRole) {
        case 0: // Student
          await _loginStudent();
          break;
        case 1: // Teacher
          await _loginTeacher();
          break;
        case 2: // Admin
          _loginAdmin();
          break;
      }
    } catch (e) {
      _showError('An error occurred: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginStudent() async {
    final id = _idController.text.trim();
    final email = _emailController.text.trim();

    if (id.isEmpty || email.isEmpty) {
      _showError('Please enter both Student ID and Email');
      return;
    }

    // Hardcoded test credentials for testing
    if (id == 'student1' && email == 'student@test.com') {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavigationPage()),
        );
      }
      return;
    }

    try {
      final response = await _client
          .from('students')
          .select()
          .eq('student_id', id)
          .eq('email', email)
          .maybeSingle();

      if (response != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavigationPage()),
        );
      } else {
        _showError('Invalid Student ID or Email');
      }
    } catch (e) {
      _showError('Login failed. Please try again.');
    }
  }

  Future<void> _loginTeacher() async {
    final id = _idController.text.trim();
    final email = _emailController.text.trim();

    if (id.isEmpty || email.isEmpty) {
      _showError('Please enter both Teacher ID and Email');
      return;
    }

    // Hardcoded test credentials for testing
    if (id == 'teacher1' && email == 'teacher@test.com') {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TeacherNavigationPage()),
        );
      }
      return;
    }

    try {
      final response = await _client
          .from('teachers')
          .select()
          .eq('teacher_id', id)
          .eq('email', email)
          .maybeSingle();

      if (response != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TeacherNavigationPage()),
        );
      } else {
        _showError('Invalid Teacher ID or Email');
      }
    } catch (e) {
      _showError('Login failed. Please try again.');
    }
  }

  void _loginAdmin() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showError('Please enter both Username and Password');
      return;
    }

    if (username == 'admin' && password == 'admin123') {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyAdmin()),
        );
      }
    } else {
      _showError('Invalid Admin credentials');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = _roles[_selectedRole];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              role.gradient[0].withOpacity(0.08),
              Colors.white,
              role.gradient[1].withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Top bar with role tabs on the right
                  _buildTopBar(),
                  const SizedBox(height: 40),
                  // Branding / Header
                  _buildHeader(role),
                  const SizedBox(height: 40),
                  // Login form card
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildLoginCard(role),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: List.generate(_roles.length, (index) {
        final role = _roles[index];
        final isSelected = _selectedRole == index;
        return Padding(
          padding: const EdgeInsets.only(left: 6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _switchRole(index),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? role.color.withOpacity(0.15)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? role.color : Colors.grey.shade300,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        role.icon,
                        size: 16,
                        color: isSelected ? role.color : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        role.label.split(' ').first, // "Student", "Teacher", "Admin"
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? role.color : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader(_RoleConfig role) {
    return Column(
      children: [
        // Icon in a gradient circle
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: role.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: role.color.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(role.icon, size: 45, color: Colors.white),
        ),
        const SizedBox(height: 20),
        const Text(
          'Academic Management',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          role.label,
          style: TextStyle(
            fontSize: 16,
            color: role.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(_RoleConfig role) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: role.color.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sign In',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: role.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _selectedRole == 2
                ? 'Enter your admin credentials'
                : 'Enter your ID and email to continue',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          // Form fields based on role
          if (_selectedRole == 0 || _selectedRole == 1) ...[
            _buildTextField(
              controller: _idController,
              label: _selectedRole == 0 ? 'Student ID' : 'Teacher ID',
              icon: Icons.badge_outlined,
              color: role.color,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              color: role.color,
              keyboardType: TextInputType.emailAddress,
            ),
          ] else ...[
            _buildTextField(
              controller: _usernameController,
              label: 'Username',
              icon: Icons.person_outline,
              color: role.color,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock_outline,
              color: role.color,
              isPassword: true,
            ),
          ],
          const SizedBox(height: 28),
          // Login button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: role.color,
                foregroundColor: Colors.white,
                elevation: 3,
                shadowColor: role.color.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Login as ${role.label.split(' ').first}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword ? _obscurePassword : false,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        prefixIcon: Icon(icon, color: color, size: 22),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              )
            : null,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      onSubmitted: (_) => _handleLogin(),
    );
  }
}

class _RoleConfig {
  final String label;
  final IconData icon;
  final Color color;
  final List<Color> gradient;

  _RoleConfig({
    required this.label,
    required this.icon,
    required this.color,
    required this.gradient,
  });
}
