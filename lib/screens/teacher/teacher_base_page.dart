import 'package:flutter/material.dart';
import 'teacher_navigation_bar.dart';

class TeacherBasePage extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onNavItemTapped;

  const TeacherBasePage({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onNavItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: TeacherBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onNavItemTapped,
      ),
    );
  }
}