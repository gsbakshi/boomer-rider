import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../helpers/platform_keys.dart';
import '../helpers/data_tranform.dart';
import '../helpers/http_exception.dart';

class MapsProvider with ChangeNotifier {
  late Position _currentPosition;

  late String _countryCode;

  Position get currentPosition => _currentPosition;

  String get countryCode => _countryCode;

  Future<String> _reverseGeocode(Position position) async {
    try {
      String address = '';
      final apiKey = mapsAPI;
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey';
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      if (data['error_message'] != null) {
        throw HttpException(data['error_message']);
      }

      String street = data['results'][0]['address_components'][0]['long_name'];
      String road = data['results'][0]['address_components'][1]['long_name'];
      String locality =
          data['results'][0]['address_components'][2]['long_name'];
      String state = data['results'][0]['address_components'][4]['long_name'];
      _countryCode =
          (data['results'][0]['address_components'][7]['short_name'] as String)
              .toLowerCase();
      address = street + ', ' + road + ' ' + locality + ', ' + state;
      return address;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> _getMapPosition(GoogleMapController mapController) async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _currentPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition = new CameraPosition(
      target: latLngPosition,
      zoom: 14,
    );

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
  }

  Future<void> locatePosition(
    GoogleMapController mapController,
    TextEditingController textController,
  ) async {
    try {
      await _getMapPosition(mapController);
      String address = await _reverseGeocode(_currentPosition);
      textController.text = address;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> getLatLng(
    String value,
    GoogleMapController mapController,
  ) async {
    List<Location> locations = await locationFromAddress(value);

    final latLngData = convertGeoCodingToMap(locations);

    _currentPosition = Position(
      latitude: double.tryParse(latLngData['latitude']!)!,
      longitude: double.tryParse(latLngData['longitude']!)!,
      timestamp: DateTime.tryParse(latLngData['timestamp']!)!,
      accuracy: 0.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );

    LatLng latLngPosition = LatLng(
      _currentPosition.latitude,
      _currentPosition.longitude,
    );

    CameraPosition cameraPosition = new CameraPosition(
      target: latLngPosition,
      zoom: 14,
    );

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
  }

  Future<void> findPlace(String address) async {
    try {
      final apiKey = mapsAPI;
      final url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$address&key=$apiKey&sessiontoken=1234567890&components=country:$_countryCode';
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      // print(data);
      if (data['error_message'] != null) {
        throw HttpException(data['error_message']);
      }
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
