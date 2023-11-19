import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testing/helper/auth_exception.dart';
import 'package:testing/helper/rsa.dart';
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

  static Future<List> getPublicKey(String password) async {
    List publicKey = [];

    QuerySnapshot usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
      if (userDoc.data() != null && userDoc.data() is Map<String, dynamic>) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        if (userData.containsKey('publicKey') &&
            userData['deviceId'] == password) {
          publicKey.add(userData['publicKey']);
        }
      }
    }

    return publicKey;
  }
  
  static Future<List> getPrivateKey(List publicKey) async {
    List privateKey = [];
    var subCollectionName = publicKey.join(",");

    DocumentSnapshot<Map<String, dynamic>> usersSnapshot =
        await FirebaseFirestore.instance.collection('devs').doc(subCollectionName).get();

    if(usersSnapshot.exists){
      Map<String, dynamic> userData = usersSnapshot.data() as Map<String, dynamic>;
      if(userData.containsKey('privateKey')){
        privateKey.add(userData['privateKey']);
      }
    }

    return privateKey;
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
        var allKey = Rsa.generateKeypair();
        var publicKey = allKey[0];
        var privateKey = allKey[1];
        var encryptedPassword = Rsa.encrypt(publicKey, password);
        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: encryptedPassword.join(","),
        );
        User? user = userCredential.user;
        await user?.updateDisplayName(username);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': email,
          'deviceId': password,
          'username': username,
          'publicKey': publicKey
        });
        await FirebaseFirestore.instance
            .collection('devs')
            .doc(publicKey.join(","))
            .set({'privateKey': privateKey});
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
      var publicKey = (await getPublicKey(password))[0];
      var privateKey = (await getPrivateKey(publicKey))[0];
      print("Public Key: $publicKey");
      print("Private Key: $privateKey");
      var encryptedPassword = await Rsa.encrypt(publicKey, password);
      var decryptedPassword = await Rsa.decrypt(privateKey, encryptedPassword);
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: email, password: encryptedPassword.join(","));
      print(userCredential);
      print("DECRYPTED PASSWORD:");
      print(decryptedPassword);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } on FirebaseAuthException catch (e) {
      AuthExecption.handleLogin(e);
    }
  }

  static Future<void> handleLogout(BuildContext context) async {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginView()));
  }

  static bool isLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }
}
