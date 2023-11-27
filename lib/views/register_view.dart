import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing/firebase_options.dart';
import 'package:testing/helper/auth_handler.dart';
import 'package:testing/helper/custom_scaffold.dart';
import 'package:testing/helper/custom_validator.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  String _id = '';
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final SharedPreferences prefs;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _phoneController = TextEditingController();
    print("Init state called");
    getUID();
    initializeAppAndCheckDeviceId();
  }

  Future<void> initializeAppAndCheckDeviceId() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await getUID();
    await getPrefs();
    await _checkDeviceIdAndNavigate();
  }

  Future getPrefs() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      prefs = pref;
    });
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

    await prefs.setString("_id", password);
    await prefs.setStringList("storedDeviceId", storedDeviceId);

    CustomValidator.firstNavigate(context);
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
            return Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                      margin: EdgeInsets.all(20),
                      child: Text(
                        "Unique device id: $_id",
                        style: TextStyle(color: CustomScaffold.color4),
                      )),
                  CustomScaffold.makeTextField(
                      _emailController,
                      "Enter your email here",
                      TextInputType.emailAddress,
                      Icon(Icons.mail),
                      _formKey),
                  CustomScaffold.makeTextField(
                      _usernameController,
                      "Enter your username here",
                      TextInputType.name,
                      Icon(Icons.person),
                      _formKey),
                  CustomScaffold.makeTextField(
                      _phoneController,
                      "Enter your phone number here",
                      TextInputType.phone,
                      Icon(Icons.phone),
                      _formKey),
                  CustomScaffold.makeElevatedButton("Register", context,
                      formKey: _formKey,
                      asyncFunction: () => AuthHandler.handleRegister(
                          _emailController.text,
                          _usernameController.text,
                          _id,
                          _phoneController.text,
                          context)),
                ],
              ),
            );
          default:
            return const Text("Loading...");
        }
      }),
    );
  }
}
