import 'package:boomer_rider/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/maps_provider.dart';
import '../providers/user_provider.dart';

import '../helpers/http_exception.dart';

import '../models/address.dart';
import '../models/predicted_places.dart';

import '../widgets/search_field.dart';
import '../widgets/predicted_tile.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key? key}) : super(key: key);

  static const routeName = '/search';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _pickUpController = TextEditingController();

  final _dropOffController = TextEditingController();

  bool _isInit = true;

  late final dropOffLocation;

  late Address _dropOffAddress;

  List<PredictedPlaces> predictedList = [];

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

  void _updateDropOff() {
    Provider.of<UserProvider>(
      context,
      listen: false,
    ).updateDropOffLocationAddress(_dropOffAddress);
    Navigator.of(context).pop('obtainDirection');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pickUpController.dispose();
    _dropOffController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final addressProvider = Provider.of<UserProvider>(
        context,
        listen: false,
      );
      _pickUpController.text = addressProvider.pickupLocation!.address ?? '';
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Drop Off'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColorDark,
      ),
      bottomSheet: _dropOffController.text.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorDark,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 4,
                    spreadRadius: 0.5,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: CustomButton(
                label: 'Continue',
                onTap: _updateDropOff,
              ),
            ),
      body: Consumer<MapsProvider>(
        builder: (ctx, places, _) {
          void _autoCompleteSearch(value) async {
            try {
              if (value.length == 0) {
                setState(() {
                  predictedList = [];
                });
                return;
              }
              if (value.isEmpty) {
                return;
              }
              await places.findPlace(value);
              predictedList = places.predictedList;
            } on HttpException catch (error) {
              var errorMessage = 'Request Failed';
              print(error);
              _snackbar(errorMessage + ' : ' + error.toString());
            } catch (error) {
              const errorMessage =
                  'Could not autocomplete search request. Please try again later.';
              print(error);
              _snackbar(errorMessage);
            }
          }

          void _getPlaceDetails(String placeId) async {
            try {
              await places.getPlaceDetails(placeId);
              _dropOffAddress = places.dropoffLocation;
              setState(() {
                _dropOffController.text = _dropOffAddress.address ?? '';
              });
            } on HttpException catch (error) {
              var errorMessage = 'Request Failed';
              print(error);
              _snackbar(errorMessage);
            } catch (error) {
              const errorMessage =
                  'Could not locate you. Please try again later.';
              print(error);
              _snackbar(errorMessage);
            }
          }

          return Column(
            children: [
              SearchField(
                icon: Icons.my_location,
                textField: TextField(
                  controller: _pickUpController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Pick up location',
                    hintStyle: TextStyle(
                      color: Color(0xffB8AAA3),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SearchField(
                icon: Icons.location_pin,
                textField: TextField(
                  controller: _dropOffController,
                  textInputAction: TextInputAction.send,
                  decoration: InputDecoration(
                    hintText: 'Where to?',
                    hintStyle: TextStyle(
                      color: Color(0xffB8AAA3),
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: _autoCompleteSearch,
                ),
              ),
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorDark,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 2,
                      spreadRadius: 0.5,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  itemCount: predictedList.length,
                  itemBuilder: (ctx, i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: PredictedTile(
                      predictedList[i],
                      onTap: () => _getPlaceDetails(predictedList[i].placeId!),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
