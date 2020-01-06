import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/picked_location.dart';

class PickedLocationsProvider with ChangeNotifier {
  List<PickedLocation> _pickedLocations = [];
  Uuid uuid = Uuid();

  List<PickedLocation> get pickedLocations => _pickedLocations;

  Future<void> getLocations() async {
    await Future.delayed(Duration(seconds: 1));
    notifyListeners();
  }

  Future<void> addLocation(PickedLocation newLocation) async {
    await Future.delayed(Duration(seconds: 1));
    newLocation.id = uuid.v4();
    _pickedLocations.add(newLocation);
    notifyListeners();
  }

  Future<void> deleteLocation(String locationId) async {
    await Future.delayed(Duration(seconds: 1));
    _pickedLocations =
        _pickedLocations.where((loc) => loc.id != locationId).toList();
    notifyListeners();
  }
}
