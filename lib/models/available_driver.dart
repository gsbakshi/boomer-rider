class AvailableDriver {
  AvailableDriver({
    this.driverId,
    this.latitude,
    this.longitude,
  });

  String? driverId;
  double? latitude;
  double? longitude;

  AvailableDriver copyWith({
    String? driverId,
    double? latitude,
    double? longitude,
  }) {
    return AvailableDriver(
      driverId: driverId ?? this.driverId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  String toString() =>
      'AvailableDriver(driverId: $driverId, latitude: $latitude, longitude: $longitude)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AvailableDriver && other.driverId == driverId;
  }

  @override
  int get hashCode =>
      driverId.hashCode ^ latitude.hashCode ^ longitude.hashCode;
}
