import 'dart:ffi';
import 'dart:html';

import 'dart:async';

import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:geocoder/geocoder.dart';

class MyLocation extends StatefulWidget {
  MyLocation({Key? key}) : super(key: key);

  @override
  State<MyLocation> createState() => _MyLocationState();
}

class _MyLocationState extends State<MyLocation> {
  LocationData? _currentPosition;
  String? _address, _dateTime;
  GoogleMapController? mapController;
  Marker? marker;
  Location location = Location();

  GoogleMapController? _controller;
  LatLng _initialcameraposition = LatLng(0.5937, 0.9629);
  @override
  void initState() {
    //todo
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
            child: Container(
          child: Center(
              child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 2.5,
                width: MediaQuery.of(context).size.width,
                child: GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: _initialcameraposition, zoom: 15),
                  mapType: MapType.normal,
                  onMapCreated: _onMapCreated,
                  myLocationEnabled: true,
                ),
              ),
              SizedBox(
                height: 3,
              ),
              if (_dateTime != null)
                Text("Date/Time : $_dateTime",
                    style: TextStyle(fontSize: 15, color: Colors.white)),
              SizedBox(
                height: 3,
              ),
              if (_currentPosition != null)
                Text(
                    "Latidude: ${_currentPosition!.latitude},Longitude ${_currentPosition!.longitude}",
                    style:
                        TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              SizedBox(
                height: 3,
              ),
              if (_address != null)
                Text(
                  "Address: $_address",
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              SizedBox(
                height: 3,
              )
            ],
          )),
        )),
      ),
    );
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
    _initialcameraposition = LatLng(
        _currentPosition?.latitude ?? 0.0, _currentPosition?.longitude ?? 0.0);
    location.onLocationChanged.listen((currentLocation) {
      setState(() {
        _currentPosition = currentLocation;
        _initialcameraposition = LatLng(
            currentLocation.latitude ?? 0.0, currentLocation.longitude ?? 0.0);

        var now = DateTime.now();
        _dateTime = DateFormat('EEE d MMM kk:mm:ss').format(now);
        _getAdress(_currentPosition?.latitude, _currentPosition?.longitude)
            .then((value) {
          setState(() {
            _address = "${value.first.addressLine}";
          });
        });
      });
    });
  }

  void _onMapCreated(GoogleMapController controller) {}

  Future<List<Address>> _getAdress(double? latitude, double? longitude) async {
    final coordinates = new Coordinates(latitude, longitude);
    List<Address> add =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    return add;
  }
}
