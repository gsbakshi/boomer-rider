import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../helpers/firebase_utils.dart';

import 'auth.dart';

class UserProvider with ChangeNotifier {
  void update(Auth auth) {
    authToken = auth.token;
    userId = auth.userId;
  }

  late String? authToken;
  late String? userId;


  Future<void> fetchUserDetails() async {
    try {
      final url = '$usersRef/$userId.json';
      final response = await http.get(Uri.parse(url));
      print(response);
    } catch (error) {
      print(error);
    }
  }
}