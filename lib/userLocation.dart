import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'dart:async';

class CurrentLocation {
  // LocationData? currentPosition;
  Location location = Location();
  Future<LocationData?> getLoc() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        // return ;
        return null;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted == PermissionStatus.denied) return null;
    }
    return await location.getLocation();
  }
}
