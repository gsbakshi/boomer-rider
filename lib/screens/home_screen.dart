import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import '../providers/ride_provider.dart';
import '../providers/user_provider.dart';
import '../providers/maps_provider.dart';

import '../helpers/pricing_helper.dart';
import '../helpers/http_exception.dart';
import '../helpers/direction_helper.dart';

import '../models/address.dart';
import '../models/direction_details.dart';

import '../widgets/icon_card.dart';
import '../widgets/app_drawer.dart';
import '../widgets/search_button.dart';
import '../widgets/custom_button.dart';
import '../widgets/add_new_address.dart';
import '../widgets/decorated_wrapper.dart';
import '../widgets/address_list_by_type.dart';
import '../widgets/floating_appbar_wrapper_with_textfield.dart';

import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Completer<GoogleMapController> _controller = Completer();

  late GoogleMapController newMapController;

  final _currentLocationInputController = TextEditingController();

  DirectionDetails tripDetails = DirectionDetails();

  List<LatLng> plineCoordinates = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markers = {};
  Set<Circle> circles = {};

  bool _loading = false;

  bool driversLoaded = false;

  int _state = 1;

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

  Future<void> updateAvailableDriversOnMap() async {
    setState(() {
      markers.clear();
    });
    final tMarkers = await Provider.of<MapsProvider>(
      context,
      listen: false,
    ).getAvailableDriverMarkers(
      createLocalImageConfiguration(
        context,
        size: Size(2, 2),
      ),
    );
    setState(() {
      markers = tMarkers;
    });
  }

  Future<void> locateOnMap() async {
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
      await mapProvider.initGeofire(updateAvailableDriversOnMap, driversLoaded);
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

  Future<void> onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
    newMapController = controller;
    await locateOnMap();
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
      final initialPosition = user.pickupLocation!;
      final finalPosition = user.dropOffLocation!;

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
          120,
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

      polylineSet.clear();
      setState(() {
        tripDetails = details;
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
        markers.add(pickupMarker);
        markers.add(dropoffMarker);
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

  Future<void> obtainDirection(dynamic value) async {
    if (value == 'obtainDirection') {
      setState(() {
        _loading = true;
      });
      await getPlaceDirections();
      setState(() {
        _loading = false;
        _state = 2;
      });
    }
  }

  Future<void> _resetApp() async {
    setState(() {
      _loading = true;
    });
    if (_state == 3) {
      try {
        await Provider.of<RideProvider>(
          context,
          listen: false,
        ).cancelRideRequest();
      } on HttpException catch (error) {
        var errorMessage = 'Request Failed';
        print(error);
        _snackbar(errorMessage);
      } catch (error) {
        const errorMessage = 'Could not cancel request.';
        print(error);
        _snackbar(errorMessage);
      }
    }
    Provider.of<UserProvider>(context, listen: false).clearLocation();
    setState(() {
      polylineSet.clear();
      markers.clear();
      circles.clear();
      plineCoordinates.clear();
      _currentLocationInputController.clear();
      newMapController.dispose();
      _state = 1;
    });
    await locateOnMap();
    setState(() {
      _loading = false;
    });
  }

  Future<void> _requestRide() async {
    setState(() {
      _state = 3;
    });
    await Provider.of<RideProvider>(context, listen: false).saveRideRequest();
  }

  Future<void> _addAddress(String address, String tag, String name) async {
    try {
      final addressProvider = Provider.of<UserProvider>(
        context,
        listen: false,
      );
      final pickupLocation = addressProvider.pickupLocation;
      if (address == pickupLocation!.address) {
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
    final pickupLocation = Provider.of<UserProvider>(
      context,
      listen: false,
    ).pickupLocation;
    showModalBottomSheet(
      context: context,
      shape: modalSheetShape,
      isScrollControlled: true,
      builder: (_) => AddNewAddress(
        addAddress: _addAddress,
        label: label,
        getLocationAddress: pickupLocation?.address ?? '',
      ),
    );
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

  void showAddressesByType(String label, double height) async {
    final res = await showModalBottomSheet(
      context: context,
      shape: modalSheetShape,
      isScrollControlled: true,
      builder: (_) => Container(
        constraints: BoxConstraints(
          minHeight: height * 0.5,
          maxHeight: height * 0.7,
        ),
        child: AddressListByType(
          label: label,
          addAddress: () {
            Navigator.of(context).pop();
            addAddressModalSheet(label);
          },
          deleteAddress: _deleteAddress,
        ),
      ),
    );
    await obtainDirection(res);
  }

  double mapBottomPadding(double queryHeight) {
    double bottomPad = 70;
    if (_state == 1) {
      bottomPad = queryHeight * 0.32;
    } else if (_state == 2) {
      bottomPad = queryHeight * 0.44;
    } else if (_state == 3) {
      bottomPad = queryHeight * 0.25;
    }
    return bottomPad;
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
  }

  @override
  void dispose() {
    _currentLocationInputController.dispose();
    newMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      drawer: AppDrawer(),
      floatingActionButtonLocation:
          _state == 1 ? null : FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _state == 1
          ? null
          : FloatingActionButton(
              onPressed: _resetApp,
              backgroundColor: Theme.of(context).accentColor,
              child: Icon(Icons.close),
            ),
      body: Stack(
        children: [
          Consumer<MapsProvider>(
            builder: (ctx, maps, _) => FutureBuilder(
              future: maps.checkPermissions(),
              builder: (ctx, snapshot) => maps.isPermissionsInit
                  ? CircularProgressIndicator(
                      color: Theme.of(context).accentColor,
                    )
                  : GoogleMap(
                      myLocationEnabled: true,
                      padding: EdgeInsets.only(
                          bottom: mapBottomPadding(size.height)),
                      polylines: polylineSet,
                      markers: markers,
                      circles: circles,
                      initialCameraPosition: _kGooglePlex,
                      onMapCreated: onMapCreated,
                    ),
            ),
          ),
          Positioned(
            top: 0,
            child: FloatingAppBarWrapperWithTextField(
              height: size.height * 0.072,
              width: size.width,
              leadingIcon: Icons.menu,
              onTapLeadingIcon: _openDrawer,
              hintLabel: 'Your Location',
              controller: _currentLocationInputController,
              onSubmitted: onLocationInput,
            ),
          ),
          Positioned(
            bottom: 0,
            child: AnimatedSize(
              duration: Duration(milliseconds: 360),
              vsync: this,
              curve: Curves.easeOut,
              child: Container(
                constraints:
                    _state == 1 ? null : BoxConstraints(maxHeight: 0.0),
                width: size.width,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
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
                            await obtainDirection(res);
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
                                          ? () => showAddressesByType(
                                              label, size.height)
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
          Positioned(
            bottom: 0,
            child: AnimatedSize(
              duration: Duration(milliseconds: 240),
              vsync: this,
              curve: Curves.bounceInOut,
              child: Container(
                constraints:
                    _state == 2 ? null : BoxConstraints(maxHeight: 0.0),
                width: size.width,
                margin: _state == 2
                    ? const EdgeInsets.symmetric(vertical: 70)
                    : null,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
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
                          'Select Ride',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColorDark
                                .withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Image.asset(
                              'assets/images/taxi.png',
                            ),
                            title: Text(
                              'Car',
                              style: TextStyle(
                                color: Color(0xffB8AAA3),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              tripDetails.distanceText ?? '-- km',
                              style: TextStyle(
                                color: Color(0xffB8AAA3),
                              ),
                            ),
                            trailing: Text(
                              '\$${PricingHelper.calculateFares(tripDetails.durationValue ?? 0, tripDetails.distanceValue ?? 0).toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Color(0xffB8AAA3),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColorDark
                                .withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            onTap: () {
                              print('Change Payment Method');
                            },
                            leading: Icon(
                              Icons.money,
                              color: Color(0xffB8AAA3),
                            ),
                            trailing: Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xffB8AAA3),
                            ),
                            title: Text(
                              'Cash',
                              style: TextStyle(
                                color: Color(0xffB8AAA3),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        CustomButton(
                          label: 'Request Ride',
                          onTap: _requestRide,
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
              child: AnimatedSize(
                duration: Duration(milliseconds: 240),
                vsync: this,
                curve: Curves.bounceInOut,
                child: Container(
                  height: size.height * 0.2,
                  constraints:
                      _state == 3 ? null : BoxConstraints(maxHeight: 0.0),
                  width: size.width,
                  margin: _state == 3
                      ? const EdgeInsets.symmetric(vertical: 70)
                      : null,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: DecoratedWrapper(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      child: Center(
                        child: DefaultTextStyle(
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(fontSize: 27),
                          child: AnimatedTextKit(
                            animatedTexts: [
                              RotateAnimatedText('Requesting a ride'),
                              RotateAnimatedText('Please wait'),
                              RotateAnimatedText('Finding a Driver'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_loading)
            Container(
              height: size.height,
              width: size.width,
              color: Colors.black26,
              child: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
