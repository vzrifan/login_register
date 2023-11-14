import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:testing/firebase_options.dart';

class CustomScaffold {
  //TODO Color for UI
  static const color1 = Color.fromARGB(255, 0, 31, 63);
  static const color2 = Color.fromARGB(255, 51, 51, 51);
  static const color3 = Color.fromARGB(255, 0, 0, 0);
  static const color4 = Color.fromARGB(255, 103, 58, 183);
  static const color5 = Color.fromARGB(255, 34, 139, 34);

  static AppBar makeAppBar(String title) {
    return AppBar(title: Text(title, style: TextStyle(color: color4)));
  }

  static FutureBuilder makeFutureBuilder(
      Widget Function(BuildContext, AsyncSnapshot<dynamic>) build) {
    return FutureBuilder(
        future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform),
        builder: build);
  }

  static TextField makeTextField(TextEditingController controller,
      String hintText, TextInputType textInputType,
      {bool enableSuggestions = true, bool autoCorrect = true}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(hintText: hintText),
      keyboardType: textInputType,
    );
  }

  static ElevatedButton makeElevatedButton(String title,
      {Future<void> Function()? asyncFunction}) {
    return ElevatedButton(
      onPressed: () async {
        if (asyncFunction != null) {
          await asyncFunction();
        }
      },
      child: Text(title),
    );
  }
}
