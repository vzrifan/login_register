import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testing/helper/auth_exception.dart';
import 'package:testing/main.dart';
import 'package:testing/views/login_view.dart';

class AuthHandler {
  static Future<List<String>> getDeviceIdFromFirestore() async {
    List<String> deviceIds = [];

    QuerySnapshot usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
      if (userDoc.data() != null && userDoc.data() is Map<String, dynamic>) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        if (userData.containsKey('deviceId')) {
          deviceIds.add(userData['deviceId']);
        }
      }
    }

    return deviceIds;
  }

  static Future<void> handleRegister(String email, String username,
      String password, BuildContext context) async {
    List<String> storedDeviceId = await getDeviceIdFromFirestore();
    print(storedDeviceId);

    if (storedDeviceId.contains(password)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      try {
        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        User? user = userCredential.user;
        await user?.updateDisplayName(username);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({'email': email, 'deviceId': password, 'username': username});
        print(userCredential);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } on FirebaseAuthException catch (e) {
        AuthExecption.handleRegister(e);
      }
    }
  }

  static Future<void> handleLogin(
      String email, String password, BuildContext context) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      print(userCredential);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } on FirebaseAuthException catch (e) {
      AuthExecption.handleLogin(e);
    }
  }

  static Future<void> handleLogout(BuildContext context) async{
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginView()));
  }

  static bool isLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }
}
