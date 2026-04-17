import 'package:flutter/material.dart';
import 'package:myapp/screens/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


Future <void> main() async{
  // Required before using async code in main
  WidgetsFlutterBinding.ensureInitialized();

  // 🔑 Initialize Supabase (connect Flutter with Supabase)
  await Supabase.initialize(
    url: 'https://ghvoiclqmczbnkgmliif.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdodm9pY2xxbWN6Ym5rZ21saWlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAzOTMyNzYsImV4cCI6MjA4NTk2OTI3Nn0.ZooL3zt10AHcSYz1L8WS0T4eEkrhrPgNKVQWUehZI4s'
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Academic Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}
