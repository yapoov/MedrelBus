import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'dart:async';

class DisplayLocation extends StatefulWidget {
  DisplayLocation({Key? key}) : super(key: key);

  @override
  State<DisplayLocation> createState() => _DisplayLocationState();
}

class _DisplayLocationState extends State<DisplayLocation> {
  LocationData? _currentPosition;
  Location location = Location();
  @override
  void initState() {
    //todo
    super.initState();
    getLoc();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_currentPosition!.longitude.toString());
  }

  getLoc() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted == PermissionStatus.denied) return;
    }
    _currentPosition = await location.getLocation();

    location.onLocationChanged.listen((currentLocation) {
      setState(() {
        _currentPosition = currentLocation;
      });
    });
  }
}
