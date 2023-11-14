import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:testing/firebase_options.dart';
import 'package:testing/helper/custom_scaffold.dart';
import 'package:testing/main.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  String _id = '';
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    print("Init state called");
    getUID();
    initializeAppAndCheckDeviceId();
  }

  Future<void> initializeAppAndCheckDeviceId() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await getUID();
    await _checkDeviceIdAndNavigate();
  }

  Future getUID() async {
    print("Getting UID...");
    String udid = await FlutterUdid.udid;
    setState(() {
      _id = udid;
    });
  }

  Future<void> _checkDeviceIdAndNavigate() async {
    final password = _id;
    List<String> storedDeviceId = await getDeviceIdFromFirestore();
    print(storedDeviceId);

    if (storedDeviceId.contains(password)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<List<String>> getDeviceIdFromFirestore() async {
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

  @override
  Widget build(BuildContext context) {
    print(_id);
    return Scaffold(
      appBar: CustomScaffold.makeAppBar("Register"),
      body: CustomScaffold.makeFutureBuilder((context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return Column(
              children: [
                Text(_id),
                TextField(
                  controller: _emailController,
                  decoration:
                      InputDecoration(hintText: "Enter your email here"),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: _usernameController,
                  decoration:
                      InputDecoration(hintText: "Enter your username here"),
                  keyboardType: TextInputType.name,
                ),
                TextButton(
                  onPressed: () async {
                    final email = _emailController.text;
                    final username = _usernameController.text;
                    final password = _id;
                    List<String> storedDeviceId =
                        await getDeviceIdFromFirestore();
                    print(storedDeviceId);

                    if (storedDeviceId.contains(password)) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    } else {
                      try {
                        final userCredential = await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                        User? user = userCredential.user;
                        await user?.updateDisplayName(username);
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userCredential.user!.uid)
                            .set({
                          'email': email,
                          'deviceId': password,
                          'username': username
                        });
                        print(userCredential);
                        Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'weak-password') {
                          print("Weak password");
                        } else if (e.code == 'email-already-in-use') {
                          print("Email is already in use");
                        } else if (e.code == 'invalid-email') {
                          print("Invalid email entered");
                        }
                      }
                    }
                  },
                  child: const Text("Register"),
                ),
              ],
            );
          default:
            return const Text("Loading...");
        }
      }),
    );
  }
}
