// base_page.dart
import 'package:flutter/material.dart';
import 'navigation_bar.dart';

/// This widget wraps any page with a bottom navigation bar
class BasePage extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onNavItemTapped;

  const BasePage({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onNavItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onNavItemTapped,
      ),
    );
  }
}