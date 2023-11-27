import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthExecption {
  static handleRegister(FirebaseAuthException e, BuildContext context) {
    print(e.code);
    if (e.code == 'weak-password') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Weak password")),
      );
    } else if (e.code == 'email-already-in-use') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email is already in use")),
      );
    } else if (e.code == 'invalid-email' || e.code=="channel-error") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please input email")),
      );
    }
  }

  static handleLogin(FirebaseAuthException e, BuildContext context) {
    print(e.code);
    if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not found")),
      );
    } else if (e.code == 'invalid-email' || e.code == 'channel-error') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please input email")),
      );
    } else if (e.code == 'wrong-password') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Wrong password")),
      );
    }
  }
}
