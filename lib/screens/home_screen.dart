import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../helpers/data_tranform.dart';

import '../widgets/app_drawer.dart';
import '../widgets/select_destination.dart';
import '../widgets/floating_appbar_wrapper_with_textfield.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Completer<GoogleMapController> _controller = Completer();

  late GoogleMapController newMapController;

  final _currentLocationInputController = TextEditingController();

  late Position currentPosition;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Future<void> locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    currentPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition = new CameraPosition(
      target: latLngPosition,
      zoom: 14,
    );

    newMapController.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    final addressData = convertGeoCodingToMap(placemarks);
    _currentLocationInputController.text = addressData['name'] as String;
  }

  Future<void> getLatLng(String value) async {
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
    newMapController.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
  }

  void _openDrawer() {
    _scaffoldKey.currentState!.openDrawer();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _currentLocationInputController.dispose();
    newMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(),
      body: Stack(
        children: [
          GoogleMap(
            myLocationEnabled: true,
            padding: EdgeInsets.only(
              bottom: query.height * 0.3,
              right: 16,
            ),
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              newMapController = controller;
              locatePosition();
            },
          ),
          Positioned(
            top: 0,
            child: FloatingAppBarWrapperWithTextField(
              height: query.height * 0.072,
              width: query.width,
              leadingIcon: Icons.menu,
              onTapLeadingIcon: _openDrawer,
              hintLabel: 'Your Location',
              controller: _currentLocationInputController,
              onSubmitted: (value) {
                getLatLng(value);
              },
            ),
          ),
          Positioned(
            bottom: 0,
            child: SafeArea(
              child: SelectDestination(
                height: query.height * 0.29,
                width: query.width,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
