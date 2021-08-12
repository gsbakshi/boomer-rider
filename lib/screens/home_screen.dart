import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../providers/user_data.dart';
import '../providers/map_provider.dart';

import '../helpers/http_exception.dart';

import '../models/address.dart';

import '../widgets/icon_card.dart';
import '../widgets/app_drawer.dart';
import '../widgets/search_button.dart';
import '../widgets/decorated_wrapper.dart';
import '../widgets/floating_appbar_wrapper_with_textfield.dart';
import '../widgets/create_new_address.dart';
import '../widgets/address_list_by_type.dart';

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
    _fetchAddresses();
  }

  @override
  void dispose() {
    _currentLocationInputController.dispose();
    newMapController.dispose();
    super.dispose();
  }

  Future<void> _fetchAddresses() async {
    await Provider.of<UserData>(context, listen: false).fetchAddressess();
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
      var mapProvider = Provider.of<MapProvider>(context, listen: false);
      await mapProvider.locatePosition(
        newMapController,
        _currentLocationInputController,
      );
      var currentPosition = mapProvider.currentPosition;
      Address pickupAddress = Address(
        longitude: currentPosition.longitude,
        latitude: currentPosition.latitude,
        address: _currentLocationInputController.text,
      );
      Provider.of<UserData>(context, listen: false)
          .updatePickUpLocationAddress(pickupAddress);
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

  void onLocationInput(String value) async {
    Provider.of<MapProvider>(context, listen: false).getLatLng(
      value,
      newMapController,
    );
  }

  Future<void> _addAddress(String address, String tag, String name) async {
    try {
      var pickupLocation =
          Provider.of<UserData>(context, listen: false).pickupLocation;
      if (address == pickupLocation.address) {
        final newAddress = Address(
          address: pickupLocation.address,
          latitude: pickupLocation.latitude,
          longitude: pickupLocation.longitude,
          tag: tag,
          name: name,
        );
        await Provider.of<UserData>(context, listen: false)
            .saveAddress(newAddress);
      } else {
        print('Attach Geocoding Logic Here');
      }
    } on HttpException catch (error) {
      var errorMessage = 'Request Failed';
      _snackbar(errorMessage);
      print(error);
    } catch (error) {
      const errorMessage = 'Could not save address. Please try again later.';
      _snackbar(errorMessage);
      print(error);
    }
  }

  void createAddressModalSheet(String label) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      builder: (_) => CreateNewAddress(
        addAddress: _addAddress,
        getLocationAddress: Provider.of<UserData>(context, listen: false)
                .pickupLocation
                .address ??
            '',
        label: label,
      ),
    );
  }

  void showAddressesByType(String label) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      builder: (_) => AddressListByType(
        label: label,
        addAddress: () {
          Navigator.of(context).pop();
          createAddressModalSheet(label);
        },
      ),
    );
  }

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
                        SearchButton(),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: addressType.map(
                            (card) {
                              bool check = Provider.of<UserData>(context,
                                      listen: false)
                                  .checkIfAddressExistsByType(card['label']);
                              var icon = card['icon'];
                              var label = card['label'];
                              return check
                                  ? IconCard(
                                      icon: icon,
                                      label: label,
                                      onTapHandler: () =>
                                          showAddressesByType(label),
                                    )
                                  : IconCard(
                                      icon: icon,
                                      label: 'Add $label',
                                      onTapHandler: () =>
                                          createAddressModalSheet(label),
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
