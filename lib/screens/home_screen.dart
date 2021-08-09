import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../widgets/decorated_wrapper.dart';
import '../widgets/icon_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const routeName = '/main';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController newMapController;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context).size;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Home Screen'),
      //   actions: [
      //     IconButton(
      //       onPressed: () {
      //         Provider.of<Auth>(context, listen: false).logout();
      //       },
      //       icon: Icon(Icons.logout),
      //     ),
      //   ],
      // ),
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
                child: DecoratedWrapper(),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: SafeArea(
              child: Container(
                // height: query.height * 0.3,
                width: query.width,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DecoratedWrapper(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
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
                            ),
                            IconCard(
                              icon: Icons.work,
                              label: 'Add Work',
                            ),
                            IconCard(
                              icon: Icons.location_pin,
                              label: 'Add Other',
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
