import 'package:flutter/material.dart';

import '../models/address.dart';

class UserData with ChangeNotifier {
  UserData(
    this.authToken,
    this.userId,
    this._addresses,
  );

  final String authToken;
  final String userId;
  List<Map<String, Address>> _addresses = [];

  List<Map<String, Address>> get addresses {
    return [..._addresses];
  }
}
