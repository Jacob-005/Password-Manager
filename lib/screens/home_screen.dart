import 'package:flutter/material.dart';
import 'package:password_manager/services/auth_service.dart';
import 'package:password_manager/services/firestore_service.dart';
import 'package:password_manager/models/password_entry.dart';
import 'package:password_manager/services/encryption_service.dart';

class HomeScreen extends StatelessWidget {
  final AuthService _auth = AuthService();
  final FirestoreService _firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Manager'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
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
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No passwords yet'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              PasswordEntry entry = snapshot.data![index];
              String decryptedPassword;
              try {
                decryptedPassword =
                    EncryptionService.decryptPassword(entry.password);
              } catch (e) {
                decryptedPassword = '[Decryption Failed]';
              }
              return ListTile(
                title: Text(entry.title),
                subtitle: Text('${entry.username} - $decryptedPassword'),
                onTap: () {
                  Navigator.pushNamed(context, '/add_edit', arguments: entry);
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    bool? confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete ${entry.title}?'),
                        content: Text('This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _firestore.deletePassword(entry.id);
                    }
                  },
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
        child: Icon(Icons.add),
      ),
    );
  }
}
