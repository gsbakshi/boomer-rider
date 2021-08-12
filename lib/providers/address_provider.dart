import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../helpers/http_exception.dart';
import '../helpers/firebase_utils.dart';

import '../models/address.dart';

import 'auth.dart';

class AddressProvider with ChangeNotifier {
  void update(Auth auth) {
    authToken = auth.token;
    userId = auth.userId;
    addresses;
  }

  late String? authToken;
  late String? userId;

  List<Address> _addresses = [];

  List<Address> get addresses {
    return [..._addresses];
  }

  late Address pickupLocation;

  void updatePickUpLocationAddress(Address pickupAddress) {
    pickupLocation = pickupAddress;
    notifyListeners();
  }

  bool checkIfAddressExistsByType(String label) {
    final addressListByType =
        _addresses.where((address) => address.tag == label).toList();
    if (addressListByType.isEmpty) {
      return false;
    }
    return true;
  }

  List<Address> addressByType(String label) {
    return _addresses.where((address) => address.tag == label).toList();
  }

  Address findAddressById(String id) {
    return _addresses.firstWhere((address) => address.id == id);
  }

  Future<void> addAddress(Address address) async {
    final url = '$usersRef/$userId/addresses.json?auth=$authToken';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'address': address.address,
          'latitude': address.latitude,
          'longitude': address.longitude,
          'tag': address.tag,
          'name': address.name,
        }),
      );
      final newAddress = Address(
        id: json.decode(response.body)['name'],
        address: address.address,
        latitude: address.latitude,
        longitude: address.longitude,
        tag: address.tag,
        name: address.name,
      );
      _addresses.insert(0, newAddress);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> deleteAddress(String id) async {
    final url = '$usersRef/$userId/addresses/$id.json?auth=$authToken';
    final existingAddressIndex =
        _addresses.indexWhere((element) => element.id == id);
    Address? existingAddress = _addresses[existingAddressIndex];
    _addresses.removeAt(existingAddressIndex);
    notifyListeners();
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode >= 400) {
      _addresses.insert(existingAddressIndex, existingAddress);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    existingAddress = null;
  }

  Future<void> fetchAddressess() async {
    final url = '$usersRef/$userId/addresses.json?auth=$authToken';
    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      if (data == null) {
        return;
      }
      final List<Address> loadedAddresses = [];
      data.forEach((addressId, addressData) {
        loadedAddresses.insert(
          0,
          Address(
            id: addressId,
            address: addressData['address'],
            latitude: addressData['latitude'],
            longitude: addressData['longitude'],
            tag: addressData['tag'],
            name: addressData['name'],
          ),
        );
      });
      _addresses = loadedAddresses;
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }
}
