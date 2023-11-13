import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:testing/firebase_options.dart';
import 'package:testing/views/login_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  String _id = '';
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
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
        MaterialPageRoute(builder: (context) => LoginView()),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<List<String>> getDeviceIdFromFirestore() async {
    List<String> deviceIds = [];

    // Query the 'users' collection in Firestore
    QuerySnapshot usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    // Iterate through each document in the 'users' collection
    for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
      // Check if the document contains the 'deviceId' field
      if (userDoc.data() != null && userDoc.data() is Map<String, dynamic>) {
        // Cast the data to Map<String, dynamic> to access the 'deviceId' field
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Check if the 'deviceId' field is present
        if (userData.containsKey('deviceId')) {
          // Add the deviceId to the list
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
      appBar: AppBar(
        title: Text("Register"),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
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
                  TextButton(
                    onPressed: () async {
                      final email = _emailController.text;
                      final password = _id;
                      List<String> storedDeviceId =
                          await getDeviceIdFromFirestore();
                      print(storedDeviceId);

                      if (storedDeviceId.contains(password)) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginView()),
                        );
                      } else {
                        try {
                          final userCredential = await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userCredential.user!.uid)
                              .set({
                            'email': email,
                            'deviceId': password,
                          });
                          print(userCredential);
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
        },
      ),
    );
  }
}
