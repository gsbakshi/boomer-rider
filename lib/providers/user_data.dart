import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../helpers/firebase_utils.dart';

import '../models/address.dart';

import 'auth.dart';

class UserData with ChangeNotifier {
  void update(Auth auth) {
    authToken = auth.token;
    userId = auth.userId;
    addresses;
    print(authToken);
    print(userId);
    print(addresses);
  }

  late String? authToken;
  late String? userId;
  // Future<String?> get name async {
  //   try {

  //   } catch (error) {
  //     print(error);
  //   }
  // }

  List<Address> _addresses = [
    Address(
      name: '1 Stockton St',
      latitude: 37.785878,
      longitude: -122.406484,
      label: 'Home',
    ),
  ];

  List<Address> get addresses {
    return [..._addresses];
  }

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
