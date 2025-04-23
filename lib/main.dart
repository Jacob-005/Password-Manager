import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:password_manager/screens/login_screen.dart';
import 'package:password_manager/screens/signup_screen.dart';
import 'package:password_manager/screens/home_screen.dart';
import 'package:password_manager/screens/add_edit_screen.dart';
import 'package:password_manager/models/password_entry.dart';
import 'package:password_manager/utils/theme.dart';

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
      theme: AppTheme.darkTheme, // Use dark theme
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => HomeScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/add_edit') {
          final args = settings.arguments as PasswordEntry?;
          return MaterialPageRoute(
            builder: (context) => AddEditScreen(entry: args),
          );
        }
        return null;
      },
    );
  }
}
