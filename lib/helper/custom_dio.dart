import 'package:dio/dio.dart';

class CustomDio {
  static Future<String> fetchFirestoreData(String endPoint) async {
    final dio = Dio();
    final response = await dio.get(
        'https://firestore.googleapis.com/v1/projects/testing-rifan/databases/(default)/documents/users/$endPoint');
    var data = "";

    if (response.statusCode == 200) {
      var document = response.data;

      var fields = document['fields'];
      var username = fields['username']['stringValue'];
      var email = fields['email']['stringValue'];
      var deviceId = fields['deviceId']['stringValue'];

      data += 'Username: $username\n';
      data += 'Email: $email\n';
      data += 'Device ID: $deviceId\n';

      print('Username: $username');
      print('Email: $email');
      print('Device ID: $deviceId');

      print('----------------------');
    } else {
      print('Failed to fetch data. Status code: ${response.statusCode}');
    }

    return data;
  }
}

// void main() async {
//   var data = await CustomDio.fetchFirestoreData("3DrNYLeXFAbNhbAFKv4awiWuWgw1");
//   print(data);
// }
