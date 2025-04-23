import 'dart:math';
import 'package:flutter/material.dart';
import 'package:password_manager/models/password_entry.dart';
import 'package:password_manager/services/firestore_service.dart';

class AddEditScreen extends StatefulWidget {
  final PasswordEntry? entry;

  const AddEditScreen({super.key, this.entry});

  @override
  _AddEditScreenState createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final FirestoreService _firestore = FirestoreService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _passwordStrength = '';
  bool _obscureText = true;

  // Evaluate password strength
  String evaluatePasswordStrength(String password) {
    if (password.isEmpty) return '';
    if (password.length < 6) return 'Weak';
    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    if (score >= 3) return 'Strong';
    if (score >= 2) return 'Medium';
    return 'Weak';
  }

  // Get color for password strength
  Color getStrengthColor(String strength) {
    switch (strength) {
      case 'Strong':
        return Colors.green;
      case 'Medium':
        return Colors.yellow;
      case 'Weak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Generate a random secure password
  String generatePassword() {
    const String chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
          12, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title;
      _usernameController.text = widget.entry!.username;
      _passwordController.text = widget.entry!.password;
      _passwordStrength = evaluatePasswordStrength(_passwordController.text);
    }
    _passwordController.addListener(() {
      setState(() {
        _passwordStrength = evaluatePasswordStrength(_passwordController.text);
      });
    });
  }

  void _showErrorSnackBar(String message) {
    String userFriendlyMessage = message;
    if (message == 'Please fill all fields') {
      userFriendlyMessage = 'Oops! Please fill in all fields to continue.';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: 6,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? 'Add Password' : 'Edit Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Password Details',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title (e.g., Gmail)',
                    prefixIcon: Icon(Icons.label),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureText
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureText,
                ),
                const SizedBox(height: 8),
                if (_passwordStrength.isNotEmpty)
                  Text(
                    'Password Strength: $_passwordStrength',
                    style: TextStyle(
                      color: getStrengthColor(_passwordStrength),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _passwordController.text = generatePassword();
                      _passwordStrength =
                          evaluatePasswordStrength(_passwordController.text);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  child: const Text('Generate Password',
                      style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () async {
                          if (_titleController.text.isNotEmpty &&
                              _usernameController.text.isNotEmpty &&
                              _passwordController.text.isNotEmpty) {
                            setState(() => _isLoading = true);
                            try {
                              if (widget.entry == null) {
                                await _firestore.addPassword(
                                  _titleController.text,
                                  _usernameController.text,
                                  _passwordController.text,
                                );
                              } else {
                                await _firestore.updatePassword(
                                  widget.entry!.id,
                                  _titleController.text,
                                  _usernameController.text,
                                  _passwordController.text,
                                );
                              }
                              Navigator.pop(context);
                            } catch (e) {
                              _showErrorSnackBar('Error saving password: $e');
                            } finally {
                              setState(() => _isLoading = false);
                            }
                          } else {
                            _showErrorSnackBar('Please fill all fields');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(widget.entry == null ? 'Save' : 'Update'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
