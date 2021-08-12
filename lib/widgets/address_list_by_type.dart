import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_data.dart';

import 'custom_button.dart';

class AddressListByType extends StatelessWidget {
  const AddressListByType({
    Key? key,
    required this.label,
    required this.addAddress,
  }) : super(key: key);

  final void Function() addAddress;
  final String label;

  @override
  Widget build(BuildContext context) {
    var addressList =
        Provider.of<UserData>(context, listen: false).addressByType(label);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saved Addresses - $label',
            style: Theme.of(context).textTheme.headline4,
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 30, top: 10, right: 120),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).primaryColorLight,
                  width: 2,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: addressList.map(
                  (address) {
                    late IconData icon;
                    if (label == 'Home') icon = Icons.home;
                    if (label == 'Work') icon = Icons.work;
                    if (label == 'Other') icon = Icons.location_pin;
                    return ListTile(
                      tileColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: Icon(
                        icon,
                        color: Color(0xffB8AAA3),
                      ),
                      title: Text(
                        address.name!,
                        style: TextStyle(color: Color(0xffB8AAA3)),
                      ),
                      subtitle: Text(
                        address.address!,
                        style: TextStyle(color: Color(0xffB8AAA3)),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          ),
          CustomButton(
            label: 'Add Address',
            onTap: addAddress,
          ),
        ],
      ),
    );
  }
}
