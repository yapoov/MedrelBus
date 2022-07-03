// import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:http/retry.dart';
// import 'package:medrel_bus/busLines.json' as busLines;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math' as math;
// import 'dart:math' as math;

import 'package:location/location.dart';

class DisplayBusLine extends StatefulWidget {
  String busId;

  DisplayBusLine({Key? key, required this.busId}) : super(key: key);

  @override
  State<DisplayBusLine> createState() => _BusLineState(busLineId: busId);
}

class _BusLineState extends State<DisplayBusLine> {
  String busLineId;
  _BusLineState({required this.busLineId});
  @override
  Widget build(BuildContext context) {
    final BusDataHTTP httpSservice = BusDataHTTP();
    return Card(
        shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: FutureBuilder(
          future: httpSservice.getStops(busLineId),
          builder: (context, AsyncSnapshot<BusLine> snapshot) {
            if (snapshot.hasData) {
              BusLine? busLine = snapshot.data;
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    ExpansionTile(
                        title: Container(
                            padding: EdgeInsets.all(5),
                            child: Text(busLine!.line_name,
                                style: TextStyle(fontSize: 18))),
                        expandedAlignment: Alignment.center,
                        children: <Widget>[
                          ListView.separated(
                              shrinkWrap: true,
                              itemCount: busLine!.station_list.length,
                              itemBuilder: (context, i) {
                                return ListTile(
                                  title: Text(
                                      busLine!.station_list[i].stationName),
                                  trailing: busLine!.station_list[i].existBus
                                      ? const Icon(Icons.check)
                                      : const Icon(Icons.circle_outlined),
                                );
                              },
                              separatorBuilder: (context, i) {
                                return const Divider();
                              })
                        ])
                  ],
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ));
  }
}

class NearestBusStop extends StatefulWidget {
  NearestBusStop({Key? key}) : super(key: key);

  @override
  State<NearestBusStop> createState() => _NearestBusStopState();
}

class _NearestBusStopState extends State<NearestBusStop> {
  LocationData? _currentLoc;
  Location location = Location();

  BusStop? nearestBusStop;
  var myLoc = Location();
  BusDataHTTP busLineHTTP = BusDataHTTP();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLoc();
    getNearest();
    // busLineHTTP.generateData();
  }

  getNearest() async {
    await busLineHTTP.getBusLines().then((busLines) async {
      busLines.forEach((futureBusLine) async {
        await futureBusLine.then((busLine) {
          busLine.station_list.forEach((busStop) {
            // print(busLineHTTP.allBusStops.length);
            // print(busStop.busLines.length);
            if (locDistance(_currentLoc, busStop) <
                locDistance(_currentLoc, nearestBusStop)) {
              setState(() {
                nearestBusStop = busLineHTTP.allBusStops[busStop.stationId];
              });
            }
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DisplayBusStop(
            busStop: nearestBusStop ??
                BusStop(
                    stationName: '',
                    stationId: '',
                    stationSeq: 0,
                    existBus: false,
                    longitude: 0,
                    latitude: 0)),
        Text(
            "location : ${_currentLoc?.latitude.toString()},${_currentLoc?.longitude.toString()}"),
      ],
    );
  }

  double locDistance(LocationData? locData, BusStop? busStop) {
    var p = 0.017453292519943295; // Math.PI / 180
    var c = math.cos;

    var lon1 = locData?.longitude ?? 0;
    var lon2 = busStop?.longitude ?? 0;
    var lat1 = locData?.latitude ?? double.maxFinite;
    var lat2 = busStop?.latitude ?? double.maxFinite;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a));
    // double deltaLat =
    //     (locData?.latitude ?? 0) - (busStop?.latitude ?? double.maxFinite);
    // double deltaLong =
    //     (locData?.longitude ?? 0) - (busStop?.longitude ?? double.maxFinite);
    // return deltaLat * deltaLat + deltaLong * deltaLong;
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
    _currentLoc = await location.getLocation();

    location.onLocationChanged.listen((currentLocation) {
      setState(() {
        _currentLoc = currentLocation;
      });
    });
  }
}

class BusDataHTTP {
  Map<String, BusLine> allBusLines = <String, BusLine>{};
  Map<String, BusStop> allBusStops = <String, BusStop>{};

  generateData() async {
    await getBusLines().then((futureBuslineList) {
      futureBuslineList.forEach((futureBusLine) async {
        await futureBusLine.then((busLine) {});
      });
    });
  }

  Future<List<Future<BusLine>>> getBusLines() async {
    List<dynamic> busInfos =
        json.decode(await rootBundle.loadString('lib/busLines.json'));

    return busInfos.map((busInfo) async {
      var res = await getStops(busInfo['bus_id']);
      allBusLines[res.line_id] = res;
      return res;
    }).toList();
  }

  Future<BusLine> getStops(String busId) async {
    // print(json.decode(bus_line_id[0]));
    String bustStopUrl = '/travel/bus_line_detail/$busId/start';
    http.Response res = await http
        .post(Uri(scheme: 'https', host: 'api.u-money.mn', path: bustStopUrl));
    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      // if (body['result_code'] == "001") {
      if (body['line_name'] != null) {
        BusLine busLine = BusLine.fromJson(body);

        busLine.station_list.forEach((station) {
          if (!allBusStops.containsKey(station.stationId)) {
            allBusStops[station.stationId] = station;
          }
          if (!allBusStops[station.stationId]!.busLines.contains(busLine)) {
            allBusStops[station.stationId]!.busLines.add(busLine);
          }
        });
        // if(allBusStops.contains(busId))
        return busLine;
      }
    }

    return BusLine(line_name: '', line_id: '', station_list: []);
  }
}

class BusLine {
  final List<BusStop> station_list;
  final String line_name;
  final String line_id;

  BusLine({
    required this.line_name,
    required this.line_id,
    required this.station_list,
  });

  factory BusLine.fromJson(Map<String, dynamic> json) {
    return BusLine(
        line_name: json['line_name'] as String,
        line_id: json['line_id'] as String,
        station_list: json['station_list'].map<BusStop>((station) {
          var busStop = BusStop.fromJson(station);
          return busStop;
        }).toList());
  }
}

class DisplayBusStop extends StatelessWidget {
  const DisplayBusStop({Key? key, required this.busStop}) : super(key: key);
  final BusStop busStop;
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const BeveledRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Column(
        children: [
          ExpansionTile(
              title: Text(
                busStop.stationName,
                style: TextStyle(fontSize: 18),
              ),
              children: busStop.busLines.map<Widget>((e) {
                return ListTile(
                  title: Text(e.line_name),
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return DisplayBusLine(busId: e.line_id);
                    }));
                  },
                );
              }).toList())
        ],
      ),
    );
  }
}

class BusStop {
  final String stationName;
  final String stationId;
  final int stationSeq;
  final bool existBus;
  final double longitude;
  final double latitude;

  BusStop? oppositeStop;
  List<BusLine> busLines = [];

  BusStop(
      {required this.stationName,
      required this.stationId,
      required this.stationSeq,
      required this.existBus,
      required this.longitude,
      required this.latitude});

  factory BusStop.fromJson(Map<String, dynamic> json) {
    return BusStop(
        stationId: json['station_id'] as String,
        stationName: json['station_name'] as String,
        stationSeq: json['station_seq'] as int,
        existBus: json['exist_bus'] == 'Y',
        longitude: json['longitude'] as double,
        latitude: json['latitude'] as double);
  }
}
