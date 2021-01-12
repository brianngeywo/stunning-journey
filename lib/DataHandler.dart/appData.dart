import 'package:flutter/cupertino.dart';
import 'package:uber/models/address.dart';

class AppData extends ChangeNotifier {
  Address pickUpLocation;
  void updatePickupLocationAddress(Address pickupAddress) {
    pickUpLocation = pickupAddress;
    notifyListeners();
  }
}
