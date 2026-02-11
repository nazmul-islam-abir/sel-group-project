import 'package:flutter/material.dart';
import 'package:myapp/screens/Admin/Admin_Page.dart';
import 'package:myapp/screens/student/navigation_page.dart';
import 'package:myapp/screens/admin/admin_navigation_page.dart'; // <-- create this page

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Hello This My Homepage",
          style: TextStyle(
            fontSize: 20,
            color: Color.fromARGB(255, 121, 11, 11),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Student Button
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NavigationPage(),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("Student Page"),
                    SizedBox(width: 20),
                    Icon(Icons.person_3_rounded),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Admin Button
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminNavigationPage(),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("Admin Page"),
                    SizedBox(width: 20),
                    Icon(Icons.admin_panel_settings),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
