import 'package:flutter/material.dart';
import 'package:password_manager/services/auth_service.dart';
import 'package:password_manager/services/firestore_service.dart';
import 'package:password_manager/models/password_entry.dart';
import 'package:password_manager/services/encryption_service.dart';

class HomeScreen extends StatelessWidget {
  final AuthService _auth = AuthService();
  final FirestoreService _firestore = FirestoreService();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
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
                  const Icon(Icons.lock_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No passwords yet',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.grey),
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
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent.withOpacity(0.1),
                    child: Text(
                      entry.title[0].toUpperCase(),
                      style: const TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                  title: Text(entry.title),
                  subtitle: Text('${entry.username}\n$decryptedPassword'),
                  onTap: () {
                    Navigator.pushNamed(context, '/add_edit', arguments: entry);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Delete ${entry.title}?'),
                          content: const Text('This action cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await _firestore.deletePassword(entry.id);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_edit');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
