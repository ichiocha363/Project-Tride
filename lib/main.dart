import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project_tride/Constants/app_theme.dart';
import 'package:project_tride/Views/auth_gate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:project_tride/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  try {
    // ignore: deprecated_member_use
    await FirebaseAppCheck.instance.activate(
      // ignore: deprecated_member_use
      androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      // ignore: deprecated_member_use
      appleProvider: AppleProvider.deviceCheck,
    );
  } catch (e) {
    debugPrint('[AppCheck] Warning: Could not activate App Check: $e');
  }

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
