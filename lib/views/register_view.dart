import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:testing/firebase_options.dart';
import 'package:testing/helper/auth_handler.dart';
import 'package:testing/helper/custom_scaffold.dart';
import 'package:testing/main.dart';
import 'package:testing/views/login_view.dart';

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
    List<String> storedDeviceId = await AuthHandler.getDeviceIdFromFirestore();
    print(storedDeviceId);

    if (storedDeviceId.contains(password)) {
      if (AuthHandler.isLoggedIn()) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginView()),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
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
                CustomScaffold.makeTextField(_emailController,
                    "Enter your email here", TextInputType.emailAddress),
                CustomScaffold.makeTextField(_usernameController,
                    "Enter your username here", TextInputType.name),
                CustomScaffold.makeElevatedButton("Register",
                    asyncFunction: () => AuthHandler.handleRegister(
                        _emailController.text,
                        _usernameController.text,
                        _id,
                        context)),
              ],
            );
          default:
            return const Text("Loading...");
        }
      }),
    );
  }
}
