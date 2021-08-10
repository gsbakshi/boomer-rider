Map<String, String> convertGeoCodingToMap(List placemarks) {
  final Map<String, String> addressData = {};
  final values = placemarks[0].toString().split(',');
  for (var value in values) {
    final line = value.split(':');
    final tag = line[0].trim().toLowerCase();
    addressData[tag] = line[1].trim();
  }
  return addressData;
}
