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

  void _showErrorSnackBar(String message) {
    String userFriendlyMessage = message; // Default to passed message
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
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title;
      _usernameController.text = widget.entry!.username;
      _passwordController.text = widget.entry!.password;
    }
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
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
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
                            setState(() => _isLoading = false);
                            Navigator.pop(context);
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
}
