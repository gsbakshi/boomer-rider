import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/maps_provider.dart';
import '../providers/user_provider.dart';

import '../widgets/search_field.dart';

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
      _pickUpController.text = addressProvider.pickupLocation.address ?? '';
      final addressId = ModalRoute.of(context)!.settings.arguments as String?;
      if (addressId != null) {
        dropOffLocation = addressProvider.findAddressById(addressId);
        _dropOffController.text = dropOffLocation.address;
      }
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
      body: Column(
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
              onSubmitted: (value) {},
            ),
          ),
          // Container(
          //   color: Theme.of(context).primaryColorDark,
          //   child: Row(
          //     children: [
          //       Expanded(child: Container()),
          //       Padding(
          //         padding: const EdgeInsets.only(right: 16.0),
          //         child: Icon(Icons.swap_vert),
          //       ),
          //     ],
          //   ),
          // ),
          Consumer<MapsProvider>(
            builder: (ctx, places, _) => SearchField(
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
                onChanged: (value) {
                  places.findPlace(value);
                },
                onSubmitted: (value) {},
              ),
            ),
          ),
          Container(
            color: Theme.of(context).primaryColorDark,
            height: 20,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 70),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
