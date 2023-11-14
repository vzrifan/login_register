import 'package:firebase_auth/firebase_auth.dart';

class AuthExecption {
  static handleRegister(FirebaseAuthException e) {
    if (e.code == 'weak-password') {
      print("Weak password");
    } else if (e.code == 'email-already-in-use') {
      print("Email is already in use");
    } else if (e.code == 'invalid-email') {
      print("Invalid email entered");
    }
  }

  static handleLogin(FirebaseAuthException e) {
    if (e.code == 'user-not-found') {
      print("User not found");
    } else if (e.code == 'wrong-password') {
      print("Wrong password");
    }
  }
}
