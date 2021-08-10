import 'package:flutter/material.dart';

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

  @override
  void dispose() {
    _pickUpController.dispose();
    _dropOffController.dispose();
    super.dispose();
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
              onSubmitted: (value) {},
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
