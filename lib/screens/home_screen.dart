import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import '../providers/user_provider.dart';
import '../providers/maps_provider.dart';

import '../helpers/http_exception.dart';
import '../helpers/direction_helper.dart';

import '../models/address.dart';

import '../widgets/icon_card.dart';
import '../widgets/app_drawer.dart';
import '../widgets/search_button.dart';
import '../widgets/decorated_wrapper.dart';
import '../widgets/add_new_address.dart';
import '../widgets/address_list_by_type.dart';
import '../widgets/floating_appbar_wrapper_with_textfield.dart';

import 'search_screen.dart';

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

  List<LatLng> plineCoordinates = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markers = {};
  Set<Circle> circles = {};

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

  Future<bool> _checkDialog() async => await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text('Are you sure?'),
          content: Text(
            'Do you want to delete this address?',
          ),
          actions: [
            TextButton(
              child: Text(
                'No',
                style: TextStyle(color: Theme.of(context).accentColor),
              ),
              onPressed: () {
                Navigator.of(ctx).pop(false);
              },
            ),
            TextButton(
              child: Text(
                'Yes',
                style: TextStyle(color: Theme.of(context).accentColor),
              ),
              onPressed: () {
                Navigator.of(ctx).pop(true);
              },
            ),
          ],
        ),
      );

  Future<void> onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
    newMapController = controller;
    try {
      final mapProvider = Provider.of<MapsProvider>(context, listen: false);
      await mapProvider.locatePosition(
        newMapController,
        _currentLocationInputController,
      );
      final currentPosition = mapProvider.currentPosition;
      Address pickupAddress = Address(
        longitude: currentPosition.longitude,
        latitude: currentPosition.latitude,
        address: _currentLocationInputController.text,
      );
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).updatePickUpLocationAddress(pickupAddress);
    } on HttpException catch (error) {
      var errorMessage = 'Request Failed';
      print(error);
      _snackbar(errorMessage);
    } catch (error) {
      const errorMessage = 'Could not locate you. Please try again later.';
      print(error);
      _snackbar(errorMessage);
    }
  }

  void onLocationInput(String value) async {
    try {
      final mapProvider = Provider.of<MapsProvider>(context, listen: false);
      await mapProvider.getLatLng(value, newMapController);
      final geocodedAddress = mapProvider.geocodedAddress;
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).updateDropOffLocationAddress(geocodedAddress);
    } on HttpException catch (error) {
      var errorMessage = 'Request Failed';
      print(error);
      _snackbar(errorMessage);
    } catch (error) {
      const errorMessage = 'Could not locate address. Please try again later.';
      print(error);
      _snackbar(errorMessage);
    }
  }

  Future<void> getPlaceDirections() async {
    try {
      final user = Provider.of<UserProvider>(context, listen: false);
      final initialPosition = user.pickupLocation;
      final finalPosition = user.dropOffLocation;
      final pickupLatLng = LatLng(
        initialPosition.latitude!,
        initialPosition.longitude!,
      );
      final dropoffLatLng = LatLng(
        finalPosition.latitude!,
        finalPosition.longitude!,
      );
      final details = await DirectionHelper.obtainPlaceDirectionDetails(
        pickupLatLng,
        dropoffLatLng,
      );
      final polylinePoints = PolylinePoints();
      List<PointLatLng> decodedPolylinePointsResult =
          polylinePoints.decodePolyline(details.encodedPoints!);
      plineCoordinates.clear();
      if (decodedPolylinePointsResult.isNotEmpty) {
        decodedPolylinePointsResult.forEach((PointLatLng point) {
          plineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      }

      polylineSet.clear();

      setState(() {
        final polyline = Polyline(
          color: Theme.of(context).accentColor,
          polylineId: PolylineId('Place Directions'),
          jointType: JointType.round,
          points: plineCoordinates,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
        );
        polylineSet.add(polyline);
      });

      late LatLngBounds screenBounds;
      if (pickupLatLng.latitude > dropoffLatLng.latitude &&
          pickupLatLng.longitude > dropoffLatLng.longitude) {
        screenBounds = LatLngBounds(
          southwest: dropoffLatLng,
          northeast: pickupLatLng,
        );
      } else if (pickupLatLng.latitude > dropoffLatLng.latitude) {
        screenBounds = LatLngBounds(
          southwest: LatLng(dropoffLatLng.latitude, pickupLatLng.longitude),
          northeast: LatLng(pickupLatLng.latitude, dropoffLatLng.longitude),
        );
      } else if (pickupLatLng.longitude > dropoffLatLng.longitude) {
        screenBounds = LatLngBounds(
          southwest: LatLng(pickupLatLng.latitude, dropoffLatLng.longitude),
          northeast: LatLng(dropoffLatLng.latitude, pickupLatLng.longitude),
        );
      } else {
        screenBounds = LatLngBounds(
          southwest: pickupLatLng,
          northeast: dropoffLatLng,
        );
      }

      newMapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          screenBounds,
          70,
        ),
      );

      Marker pickupMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
          title: initialPosition.name,
          snippet: 'My Location',
        ),
        position: pickupLatLng,
        markerId: MarkerId('Pick Up'),
      );

      Marker dropoffMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: finalPosition.name,
          snippet: 'Drop Off Location',
        ),
        position: dropoffLatLng,
        markerId: MarkerId('Drop Off'),
      );

      setState(() {
        markers.add(pickupMarker);
        markers.add(dropoffMarker);
      });

      Circle pickupCircle = Circle(
        fillColor: Colors.cyan,
        center: pickupLatLng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.cyanAccent,
        circleId: CircleId('Pick Up circle'),
      );
      Circle dropoffCircle = Circle(
        fillColor: Colors.lime,
        center: dropoffLatLng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.limeAccent,
        circleId: CircleId('Drop Off circle'),
      );

      setState(() {
        circles.add(pickupCircle);
        circles.add(dropoffCircle);
      });
    } on HttpException catch (error) {
      var errorMessage = 'Request Failed';
      print(error);
      _snackbar(errorMessage);
    } catch (error) {
      const errorMessage = 'Could not get directions. Please try again later.';
      print(error);
      _snackbar(errorMessage);
    }
  }

  Future<void> _addAddress(String address, String tag, String name) async {
    try {
      final addressProvider = Provider.of<UserProvider>(
        context,
        listen: false,
      );
      final pickupLocation = addressProvider.pickupLocation;
      if (address == pickupLocation.address) {
        final newAddress = Address(
          address: pickupLocation.address,
          latitude: pickupLocation.latitude,
          longitude: pickupLocation.longitude,
          tag: tag,
          name: name,
        );
        await addressProvider.addAddress(newAddress);
      } else {
        final mapProvider = Provider.of<MapsProvider>(context, listen: false);
        await mapProvider.geocode(address);
        final geocodedAddress = mapProvider.geocodedAddress;
        final newAddress = Address(
          id: geocodedAddress.id,
          address: geocodedAddress.name,
          name: name,
          latitude: geocodedAddress.latitude,
          longitude: geocodedAddress.longitude,
          tag: tag,
        );
        addressProvider.addAddress(newAddress);
      }
    } on HttpException catch (error) {
      var errorMessage = 'Request Failed';
      print(error);
      _snackbar(errorMessage);
    } catch (error) {
      const errorMessage = 'Could not save address. Please try again later.';
      print(error);
      _snackbar(errorMessage);
    }
  }

  void addAddressModalSheet(String label) {
    showModalBottomSheet(
      context: context,
      shape: modalSheetShape,
      builder: (_) => AddNewAddress(
        addAddress: _addAddress,
        label: label,
        getLocationAddress: Provider.of<UserProvider>(
              context,
              listen: false,
            ).pickupLocation.address ??
            '',
      ),
    );
  }

  void _plugNewAddressToAddressByType(String label) {
    Navigator.of(context).pop();
    addAddressModalSheet(label);
  }

  Future<void> _deleteAddress(String id) async {
    try {
      bool confirm = await _checkDialog();
      if (confirm) {
        await Provider.of<UserProvider>(context, listen: false)
            .deleteAddress(id);
      } else {
        return;
      }
    } catch (error) {
      _snackbar(error.toString());
    }
  }

  void showAddressesByType(String label) async {
    final res = await showModalBottomSheet(
      context: context,
      shape: modalSheetShape,
      builder: (_) => AddressListByType(
        label: label,
        addAddress: () => _plugNewAddressToAddressByType(label),
        deleteAddress: _deleteAddress,
      ),
    );
    if (res == 'obtainDirection') {
      await getPlaceDirections();
    }
  }

  final modalSheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
  );

  List<Map<String, dynamic>> addressType = [
    {
      'icon': Icons.home,
      'label': 'Home',
    },
    {
      'icon': Icons.work,
      'label': 'Work',
    },
    {
      'icon': Icons.location_pin,
      'label': 'Other',
    },
  ];

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
    Future.delayed(Duration.zero).then(
      (_) => Provider.of<UserProvider>(
        context,
        listen: false,
      ).fetchUserDetails(),
    );
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
            polylines: polylineSet,
            markers: markers,
            circles: circles,
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
              child: Container(
                height: query.height * 0.29,
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
                        GestureDetector(
                          onTap: () async {
                            final res = await Navigator.of(context).pushNamed(
                              SearchScreen.routeName,
                            );
                            if (res == 'obtainDirection') {
                              await getPlaceDirections();
                            }
                          },
                          child: SearchButton(),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: addressType.map(
                            (card) {
                              final icon = card['icon'];
                              final label = card['label'];
                              return Consumer<UserProvider>(
                                builder: (ctx, check, _) => IconCard(
                                  icon: icon,
                                  label: check.checkIfAddressExistsByType(label)
                                      ? label
                                      : 'Add $label',
                                  onTapHandler:
                                      check.checkIfAddressExistsByType(label)
                                          ? () => showAddressesByType(label)
                                          : () => addAddressModalSheet(label),
                                ),
                              );
                            },
                          ).toList(),
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
