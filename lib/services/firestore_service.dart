import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:password_manager/models/password_entry.dart';
import 'package:password_manager/services/encryption_service.dart';

class FirestoreService {
  final CollectionReference _passwordsCollection =
      FirebaseFirestore.instance.collection('passwords');

  Future<void> addPassword(
      String title, String username, String password) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String encryptedPassword = EncryptionService.encryptPassword(password);
    await _passwordsCollection.doc(user.uid).collection('user_passwords').add({
      'title': title,
      'username': username,
      'password': encryptedPassword,
    });
  }

  Future<void> updatePassword(
      String id, String title, String username, String password) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String encryptedPassword = EncryptionService.encryptPassword(password);
    await _passwordsCollection
        .doc(user.uid)
        .collection('user_passwords')
        .doc(id)
        .update({
      'title': title,
      'username': username,
      'password': encryptedPassword,
    });
  }

  Future<void> deletePassword(String id) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _passwordsCollection
        .doc(user.uid)
        .collection('user_passwords')
        .doc(id)
        .delete();
  }

  Stream<List<PasswordEntry>> getPasswords() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return _passwordsCollection
        .doc(user.uid)
        .collection('user_passwords')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PasswordEntry.fromMap(doc.id, doc.data()))
            .toList());
  }
}
