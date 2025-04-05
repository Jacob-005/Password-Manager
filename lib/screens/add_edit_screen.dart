import 'package:flutter/material.dart';
import 'package:password_manager/models/password_entry.dart';
import 'package:password_manager/services/firestore_service.dart';

class AddEditScreen extends StatefulWidget {
  final PasswordEntry? entry; // Null for adding, populated for editing

  const AddEditScreen({super.key, this.entry});

  @override
  _AddEditScreenState createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final FirestoreService _firestore = FirestoreService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title;
      _usernameController.text = widget.entry!.username;
      _passwordController.text =
          widget.entry!.password; // Encrypted; we'll decrypt later
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? 'Add Password' : 'Edit Password'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title (e.g., Gmail)'),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isNotEmpty &&
                    _usernameController.text.isNotEmpty &&
                    _passwordController.text.isNotEmpty) {
                  if (widget.entry == null) {
                    // Add new entry
                    await _firestore.addPassword(
                      _titleController.text,
                      _usernameController.text,
                      _passwordController.text,
                    );
                  } else {
                    // Edit existing entry (we'll add this method next)
                    await _firestore.updatePassword(
                      widget.entry!.id,
                      _titleController.text,
                      _usernameController.text,
                      _passwordController.text,
                    );
                  }
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: Text(widget.entry == null ? 'Save' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}
