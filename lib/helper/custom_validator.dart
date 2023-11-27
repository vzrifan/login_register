import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../views/login_view.dart';
import 'auth_handler.dart';

class CustomValidator {
  static String currentPage = "RegisterView";
  static Map<String, List> nextPage = {
    "RegisterView": [LoginView(), HomePage()],
    "LoginView": [HomePage() /*,RegisterView()*/],
    "HomePage": [LoginView() /*RegisterView()*/]
  };

  static bool containsNextPage(String currentPage, dynamic instance) {
    return nextPage[currentPage]!.any(
      (element) => element.runtimeType == instance.runtimeType,
    );
  }

  static void navigate(BuildContext context, dynamic instance) {
    if (containsNextPage(currentPage, instance)) {
      currentPage = instance.toString();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => instance),
      );
    }
  }

  static firstNavigate(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedDeviceId = prefs.getStringList("storedDeviceId");
    final password = prefs.getString("_id");
    print(storedDeviceId);
    print(password);
    if (storedDeviceId!.contains(password)) {
      if (AuthHandler.isLoggedIn()) {
        currentPage = "HomePage";
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        LoginView loginViewInstance = LoginView();
        navigate(context, loginViewInstance);
      }
    }
  }

  static bool isValidEmail(String email) {
    RegExp emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    return emailRegex.hasMatch(email);
  }

  static bool isValidPhoneNumber(String phoneNumber) {
    RegExp phoneRegex = RegExp(
        r'^(\+\d{1,2}\s?)?(\(\d{1,4}\)|\d{1,4})[-.\s]?\d{1,4}[-.\s]?\d{1,9}$');

    return phoneRegex.hasMatch(phoneNumber);
  }
}
