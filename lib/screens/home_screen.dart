import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../providers/map_provider.dart';

import '../helpers/http_exception.dart';

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

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

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

  void _snackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0),
        backgroundColor: Theme.of(context).accentColor,
      ),
    );
  }

  Future<void> onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
    newMapController = controller;
    try {
      // await Provider.of<MapProvider>(context, listen: false)
      //     .locatePositionFromPlacemarks(
      //   newMapController,
      //   _currentLocationInputController,
      // );
      await Provider.of<MapProvider>(context, listen: false).locatePosition(
        newMapController,
        _currentLocationInputController,
      );
    } on HttpException catch (error) {
      var errorMessage = 'Request Failed';
      _snackbar(errorMessage);
      print(error);
    } catch (error) {
      const errorMessage = 'Could not locate you. Please try again later.';
      _snackbar(errorMessage);
      print(error);
    }
  }

  void onLocationInput(String value) async =>
      Provider.of<MapProvider>(context, listen: false).getLatLng(
        value,
        newMapController,
      );

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
            onMapCreated: onMapCreated,
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
              onSubmitted: onLocationInput,
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
