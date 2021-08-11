import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../helpers/platform_keys.dart';
import '../helpers/data_tranform.dart';
import '../helpers/http_exception.dart';

class MapProvider with ChangeNotifier {
  late Position currentPosition;

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
      print(response.body);
      address = data['results'][0]['formatted_address'];
      return address;
    } catch (error) {
      throw error;
    }
  }

  Future<void> _getPosition(GoogleMapController mapController) async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    currentPosition = position;

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
      print('Locate Position - Starting');
      await _getPosition(mapController);
      print('Reverse Geocode - Starting');
      String address = await _reverseGeocode(currentPosition);
      print('Address : ' + address);
      textController.text = address;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> locatePositionFromPlacemarks(
    GoogleMapController mapController,
    TextEditingController textController,
  ) async {
    try {
      await _getPosition(mapController);
      List<Placemark> placemarks = await placemarkFromCoordinates(
        currentPosition.latitude,
        currentPosition.longitude,
      );

      final addressData = convertGeoCodingToMap(placemarks);

      textController.text = addressData['name'] as String;
      print('Address : ' + addressData.toString());
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

    currentPosition = Position(
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
      currentPosition.latitude,
      currentPosition.longitude,
    );

    CameraPosition cameraPosition = new CameraPosition(
      target: latLngPosition,
      zoom: 14,
    );

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
  }
}
