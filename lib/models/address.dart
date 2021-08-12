class Address {
  Address({
    this.id,
    this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.tag,
  });

  final String? id;
  final String? name;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? tag;

  @override
  String toString() =>
      'Address : ${this.address}, lat: ${this.latitude}, lon: ${this.longitude}, tag: ${this.tag}, name: ${this.name}';
}
