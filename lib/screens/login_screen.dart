import 'package:flutter/material.dart';
import 'package:password_manager/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _showErrorSnackBar(String message) {
    // Map Firebase error messages to a user-friendly message
    String userFriendlyMessage =
        'Incorrect email or password. Please try again.';
    if (message.contains('invalid-email')) {
      userFriendlyMessage = 'Incorrect email or password. Please try again.';
    } else if (message.contains('user-not-found') ||
        message.contains('wrong-password')) {
      userFriendlyMessage =
          'Incorrect email or password. Please double-check and try again.';
    } else if (message.contains('too-many-requests')) {
      userFriendlyMessage =
          'Too many attempts. Please wait a moment and try again.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          userFriendlyMessage,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: 6,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : Column(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  print(
                                      'Login button pressed: ${_emailController.text}');
                                  setState(() => _isLoading = true);
                                  final result = await _auth.signIn(
                                    _emailController.text,
                                    _passwordController.text,
                                  );
                                  setState(() => _isLoading = false);
                                  if (result['success'] == true) {
                                    Navigator.pushReplacementNamed(
                                        context, '/home');
                                  } else {
                                    _showErrorSnackBar(
                                        result['message'] ?? 'Login failed');
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: const Text('Login'),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/signup');
                                  },
                                  child: const Text('Need an account? Sign up'),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
