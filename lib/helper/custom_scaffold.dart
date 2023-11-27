import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:testing/firebase_options.dart';
import 'package:testing/helper/custom_validator.dart';

class CustomScaffold {
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

  static TextFormField makeTextField(
      TextEditingController controller,
      String hintText,
      TextInputType textInputType,
      Icon icon,
      GlobalKey<FormState> formKey,
      {bool enableSuggestions = true,
      bool autoCorrect = true}) {
    return TextFormField(
      validator: (value) {
        if (textInputType == TextInputType.emailAddress) {
          if (!CustomValidator.isValidEmail(controller.text)) {
            return "Please input email";
          }
        } else if (textInputType == TextInputType.name) {
          if (controller.text.length < 8) {
            return "Minimum name is 8";
          }
        } else if (textInputType == TextInputType.phone) {
          if (!CustomValidator.isValidPhoneNumber(controller.text)) {
            return "Please enter valid phone number";
          }
        }
        return null;
      },
      controller: controller,
      decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: color3),
          prefixIcon: icon),
      keyboardType: textInputType,
    );
  }

  static Container makeElevatedButton(
    String title,
    BuildContext context, {
    Future<void> Function()? asyncFunction,
    GlobalKey<FormState>? formKey,
  }) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
      child: ElevatedButton(
        onPressed: () async {
          if (formKey!.currentState!.validate()) {
            if (asyncFunction != null) {
              await asyncFunction();
            }
          }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: color1,
          backgroundColor: color4,
          padding: EdgeInsets.fromLTRB(100, 10, 100, 10),
        ),
        child: Text(title),
      ),
    );
  }
}
