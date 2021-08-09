import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../widgets/icon_card.dart';
import '../widgets/app_drawer.dart';
import '../widgets/decorated_wrapper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const routeName = '/main';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Completer<GoogleMapController> _controller = Completer();

  late GoogleMapController newMapController;

  final _currentLocationInputController = TextEditingController();

  late Position _currentPosition;

  Geolocator geoLocator = Geolocator();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  void locatePosition() {

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
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              newMapController = controller;
            },
          ),
          Positioned(
            top: 0,
            child: SafeArea(
              child: Container(
                height: query.height * 0.072,
                width: query.width,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DecoratedWrapper(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _openDrawer,
                          icon: Icon(
                            Icons.menu,
                            color: Color(0xffB8AAA3),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _currentLocationInputController,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              hintText: 'Your Location',
                              hintStyle: TextStyle(
                                color: Color(0xffB8AAA3),
                              ),
                              border: InputBorder.none,
                              prefixIconConstraints: BoxConstraints(
                                maxHeight: 10,
                                minHeight: 10,
                                minWidth: 26,
                                maxWidth: 34,
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: SafeArea(
              child: Container(
                width: query.width,
                constraints: BoxConstraints(
                  minHeight: query.height * 0.285,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DecoratedWrapper(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          'Hi There',
                          style: Theme.of(context).textTheme.headline1,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Where to?',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xffB8AAA3),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).primaryColorDark,
                                blurRadius: 6,
                                spreadRadius: 0.5,
                                offset: Offset(0.7, 0.7),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: Color(0xff6D5D54),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Search Drop Off',
                                style: Theme.of(context).textTheme.headline2,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconCard(
                              icon: Icons.home,
                              label: 'Add Home',
                              onTapHandler: () {
                                print('Add Home');
                              },
                            ),
                            IconCard(
                              icon: Icons.work,
                              label: 'Add Work',
                              onTapHandler: () {
                                print('Add Work');
                              },
                            ),
                            IconCard(
                              icon: Icons.location_pin,
                              label: 'Add Other',
                              onTapHandler: () {
                                print('Add Other');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
