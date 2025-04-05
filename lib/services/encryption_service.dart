import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:firebase_auth/firebase_auth.dart';

class EncryptionService {
  static encrypt.Key _getKey() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user logged in');
    String uid = user.uid;
    String keyString = uid.padRight(32, '0').substring(0, 32);
    return encrypt.Key.fromUtf8(keyString);
  }

  static encrypt.IV _getIV() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user logged in');
    String uid = user.uid;
    String ivString = uid.padRight(16, '0').substring(0, 16);
    return encrypt.IV.fromUtf8(ivString);
  }

  static String encryptPassword(String plainText) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_getKey()));
    final encrypted = encrypter.encrypt(plainText, iv: _getIV());
    return encrypted.base64;
  }

  static String decryptPassword(String encryptedText) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_getKey()));
    try {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
      return encrypter.decrypt(encrypted, iv: _getIV());
    } catch (e) {
      print('Decryption error for "$encryptedText": $e');
      rethrow;
    }
  }
}
