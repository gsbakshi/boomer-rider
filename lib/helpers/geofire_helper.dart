import '../models/available_driver.dart';

class GeofireHelper {
  static List<AvailableDriver> availableDriversList = [];
  static void removeAvailableDriversFromList(String id) {
    final index = availableDriversList.indexWhere(
      (driver) => driver.driverId == id,
    );
    availableDriversList.removeAt(index);
  }

  static updateDriverLocation(AvailableDriver driver) {
    int index = availableDriversList.indexWhere(
      (availableDriver) => availableDriver == driver,
    );
    availableDriversList[index].copyWith(
      latitude: driver.latitude,
      longitude: driver.longitude,
    );
  }
}
