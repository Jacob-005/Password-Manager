import 'package:flutter/material.dart';
import 'package:password_manager/services/auth_service.dart';
import 'package:password_manager/services/firestore_service.dart';
import 'package:password_manager/models/password_entry.dart';
import 'package:password_manager/services/encryption_service.dart';
import 'package:password_manager/screens/add_edit_screen.dart';

class HomeScreen extends StatelessWidget {
  final AuthService _auth = AuthService();
  final FirestoreService _firestore = FirestoreService();

  HomeScreen({super.key});

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
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
        title: const Text('Password Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.health_and_safety, color: Colors.blueAccent),
            onPressed: () => Navigator.pushNamed(context, '/health'),
            tooltip: 'Password Health',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.blueAccent),
            onPressed: () async {
              try {
                await _auth.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              } catch (e) {
                _showSnackBar(context, 'Error signing out: $e');
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: StreamBuilder<List<PasswordEntry>>(
        stream: _firestore.getPasswords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 48,
                    color: Color(0xFFB0BEC5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No passwords yet',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFFB0BEC5),
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/add_edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(200, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Add Password'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final entry = snapshot.data![index];
              String decryptedPassword;
              try {
                decryptedPassword =
                    EncryptionService.decryptPassword(entry.password);
              } catch (e) {
                decryptedPassword = '[Decryption Failed: $e]';
              }
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      entry.title[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    entry.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  subtitle: Text(
                    '${entry.username}\n$decryptedPassword',
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditScreen(entry: entry),
                            ),
                          );
                        },
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Delete ${entry.title}?'),
                              content:
                                  const Text('This action cannot be undone.'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.blueAccent),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            try {
                              await _firestore.deletePassword(entry.id);
                              _showSnackBar(context, 'Password deleted');
                            } catch (e) {
                              _showSnackBar(
                                  context, 'Error deleting password: $e');
                            }
                          }
                        },
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add_edit'),
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.add),
      ),
    );
  }
}
