import 'address.dart';

class User {
  const User({
    required this.name,
    required this.mobile,
    required this.email,
    this.addressess,
  });

  final String name;
  final String mobile;
  final String email;
  final List<Address>? addressess;
}
