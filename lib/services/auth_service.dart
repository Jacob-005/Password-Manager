import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return {
        'success': true,
        'user': userCredential.user,
        'message': 'Login successful',
      };
    } catch (e) {
      return {
        'success': false,
        'user': null,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> signUp(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return {
        'success': true,
        'user': userCredential.user,
        'message': 'Signup successful',
      };
    } catch (e) {
      return {
        'success': false,
        'user': null,
        'message': e.toString(),
      };
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
