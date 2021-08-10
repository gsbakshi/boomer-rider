import 'package:flutter/material.dart';

import 'decorated_wrapper.dart';
import 'icon_card.dart';
import 'search_button.dart';

class SelectDestination extends StatelessWidget {
  const SelectDestination({
    Key? key,
    required this.height,
    required this.width,
  }) : super(key: key);

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
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
    );
  }
}
