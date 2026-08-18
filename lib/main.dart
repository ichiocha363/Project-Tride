import 'package:flutter/material.dart';
import 'package:project_tride/Constants/app_theme.dart';
import 'package:project_tride/Views/auth_gate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tride App',
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

