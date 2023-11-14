import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:testing/helper/custom_scaffold.dart';
import 'package:testing/main.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  String _id = '';
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    getUID();
  }

  Future getUID() async {
    print("Getting UID...");
    String udid = await FlutterUdid.udid;
    setState(() {
      _id = udid;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomScaffold.makeAppBar("Login"),
        body: CustomScaffold.makeFutureBuilder((context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Column(
                children: [
                  TextField(
                    controller: _emailController,
                    decoration:
                        InputDecoration(hintText: "Enter your email here"),
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextButton(
                    onPressed: () async {
                      final email = _emailController.text;
                      final password = _id;
                      try {
                        final userCredential = await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                                email: email, password: password);
                        print(userCredential);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage()));
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          print("User not found");
                        } else if (e.code == 'wrong-password') {
                          print("Wrong password");
                        }
                      }
                    },
                    child: const Text("Login"),
                  ),
                ],
              );
            default:
              return const Text("Loading...");
          }
        }));
  }
}
