import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:testing/helper/auth_handler.dart';
import 'package:testing/helper/custom_scaffold.dart';
import 'package:testing/views/register_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    title: "Flutter Demo",
    theme: ThemeData(primarySwatch: Colors.lightBlue), //TODO Color theme
    home: const RegisterView(),
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomScaffold.makeAppBar("Home Page"),
        body: CustomScaffold.makeFutureBuilder((context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              if (user?.emailVerified ?? false) {
                print("You are a verified user");
              } else {
                print("You need to verify your email first");
              }
              return Column(
                children: [
                  Text("Hello ${user?.displayName}\n\nYour full info: $user"),
                  CustomScaffold.makeElevatedButton("Logout",
                      asyncFunction: () => AuthHandler.handleLogout(context)),
                ],
              );
            default:
              return const Text("Loading...");
          }
        }));
  }
}
