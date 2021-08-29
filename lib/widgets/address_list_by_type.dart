import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

import 'custom_button.dart';

class AddressListByType extends StatelessWidget {
  AddressListByType({
    Key? key,
    required this.label,
    required this.addAddress,
    required this.deleteAddress,
  }) : super(key: key);

  final void Function() addAddress;
  final void Function(String) deleteAddress;
  final String label;

  final Color color = Color(0xffB8AAA3);

  IconData getIcon() {
    final icon;
    switch (label) {
      case 'Home':
        icon = Icons.home;
        break;
      case 'Work':
        icon = Icons.work;
        break;
      default:
        icon = Icons.location_pin;
        break;
    }
    return icon;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.headline4,
              ),
              SizedBox(height: 2),
              Text(
                'Select Drop Off Location',
                style: Theme.of(context).textTheme.headline2,
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 0, top: 10, right: 120),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).primaryColorLight,
                      width: 2,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Consumer<UserProvider>(
                  builder: (ctx, data, _) => SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30, bottom: 30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: data.addressByType(label).map(
                          (address) {
                            final icon = getIcon();
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                onTap: () {
                                  Provider.of<UserProvider>(
                                    context,
                                    listen: false,
                                  ).updateDropOffLocationAddress(address);
                                  Navigator.of(context).pop('obtainDirection');
                                },
                                isThreeLine: true,
                                leading: Icon(icon, color: color),
                                title: Text(
                                  address.name!,
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  address.address!,
                                  style: TextStyle(color: color),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete),
                                  color: color,
                                  onPressed: () => deleteAddress(address.id!),
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: CustomButton(
              label: 'Add Address',
              onTap: addAddress,
            ),
          ),
        ),
      ],
    );
  }
}
