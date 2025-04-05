import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'package:password_manager/screens/login_screen.dart';
import 'package:password_manager/screens/signup_screen.dart';
import 'package:password_manager/screens/home_screen.dart';
import 'package:password_manager/screens/add_edit_screen.dart';
import 'package:password_manager/models/password_entry.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        if (settings.name == '/add_edit') {
          final args = settings.arguments as PasswordEntry?;
          return MaterialPageRoute(
            builder: (context) => AddEditScreen(entry: args),
          );
        }
        return null; // Let routes handle other cases
      },
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
