import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../helpers/firebase_utils.dart';

import 'auth.dart';

class UserProvider with ChangeNotifier {
  Future<void> update(Auth auth) async {
    authToken = auth.token;
    userId = auth.userId;
    await fetchUserDetails();
  }

  late String? authToken;
  late String? userId;

  late String _name;
  late String _email;
  late String _mobile;

  String get name => _name;
  String get email => _email;
  String get mobile => _mobile;

  Future<void> fetchUserDetails() async {
    try {
      final url = '$usersRef/$userId.json?auth=$authToken';
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      print(data);
      if (data == null) {
        return;
      }
      _name = data['name'];
      _email = data['email'];
      _mobile = data['mobile'];
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }
}
