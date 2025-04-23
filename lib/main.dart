import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:password_manager/screens/login_screen.dart';
import 'package:password_manager/screens/signup_screen.dart';
import 'package:password_manager/screens/home_screen.dart';
import 'package:password_manager/screens/add_edit_screen.dart';
// import 'package:password_manager/screens/settings_screen.dart';
import 'package:password_manager/screens/password_health_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Password Manager',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        textTheme: const TextTheme(
          displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 16),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF1F1F1F),
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => HomeScreen(),
        '/add_edit': (context) => const AddEditScreen(),
        // '/settings': (context) => const SettingsScreen(),
        '/health': (context) => PasswordHealthScreen(),
      },
    );
  }
}
