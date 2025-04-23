import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return {'success': true};
    } catch (e) {
      String errorMessage = 'Login failed';
      if (e is FirebaseAuthException) {
        errorMessage = e.code; // e.g., 'invalid-email', 'wrong-password'
      }
      return {'success': false, 'message': errorMessage};
    }
  }

  Future<Map<String, dynamic>> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return {'success': true};
    } catch (e) {
      String errorMessage = 'Signup failed';
      if (e is FirebaseAuthException) {
        errorMessage = e.code; // e.g., 'email-already-in-use', 'weak-password'
      }
      return {'success': false, 'message': errorMessage};
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
