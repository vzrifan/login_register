import 'package:flutter/material.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:testing/helper/auth_handler.dart';
import 'package:testing/helper/custom_scaffold.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  String _id = '';
  late final TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();

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
              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomScaffold.makeTextField(
                        _emailController,
                        "Enter your email here",
                        TextInputType.emailAddress,
                        Icon(Icons.mail),
                        _formKey,
                        enableSuggestions: false,
                        autoCorrect: false),
                    CustomScaffold.makeElevatedButton(
                      "Login",
                      context,
                      formKey: _formKey,
                      asyncFunction: () => AuthHandler.handleLogin(
                          _emailController.text, _id, context),
                    ),
                  ],
                ),
              );
            default:
              return const Text("Loading...");
          }
        }));
  }
}
