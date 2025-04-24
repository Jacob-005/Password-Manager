import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with email and password
  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Sign up
  Future<void> signUp(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  // Get current user
  User? get currentUser => _auth.currentUser;
}
