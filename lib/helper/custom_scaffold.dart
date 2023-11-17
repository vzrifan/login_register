import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:testing/firebase_options.dart';

class CustomScaffold {
  //TODO Color for UI
  static const color1 = Color.fromARGB(255, 243, 238, 234);
  static const color2 = Color.fromARGB(255, 235, 227, 213);
  static const color3 = Color.fromARGB(255, 176, 166, 139);
  static const color4 = Color.fromARGB(255, 119, 107, 93);

  static AppBar makeAppBar(String title) {
    return AppBar(
      title: Text(title, style: TextStyle(color: color1)),
      backgroundColor: color4,
      elevation: 5,
    );
  }

  static FutureBuilder makeFutureBuilder(
      Widget Function(BuildContext, AsyncSnapshot<dynamic>) build) {
    return FutureBuilder(
        future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform),
        builder: build);
  }

  static TextField makeTextField(TextEditingController controller,
      String hintText, TextInputType textInputType, Icon icon,
      {bool enableSuggestions = true, bool autoCorrect = true}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: color3),
          prefixIcon: icon),
      keyboardType: textInputType,
    );
  }

  static Container makeElevatedButton(String title,
      {Future<void> Function()? asyncFunction}) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
      child: ElevatedButton(
        onPressed: () async {
          if (asyncFunction != null) {
            await asyncFunction();
          }
        },
        child: Text(title),
        style: ElevatedButton.styleFrom(
          foregroundColor: color1,
          backgroundColor: color4,
          padding: EdgeInsets.fromLTRB(100, 10, 100, 10),
        ),
      ),
    );
  }
}
