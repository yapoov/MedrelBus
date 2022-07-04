// import 'dart:ui';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/cupertino.dart';
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
          future: httpSservice.getBusLineData(busLineId),
          builder: (context, AsyncSnapshot<BusLine> snapshot) {
            if (snapshot.hasData) {
              BusLine? busLine = snapshot.data;
              return Column(
                children: <Widget>[
                  ExpansionTile(
                      title: Container(
                          padding: EdgeInsets.all(5),
                          child: Text(busLine!.lineName,
                              style: TextStyle(fontSize: 18))),
                      expandedAlignment: Alignment.center,
                      children: <Widget>[
                        ListView.separated(
                            shrinkWrap: true,
                            itemCount: busLine!.stationList.length,
                            itemBuilder: (context, i) {
                              return ListTile(
                                title:
                                    Text(busLine!.stationList[i].stationName),
                                trailing: busLine!.stationList[i].existBus
                                    ? const Icon(Icons.check)
                                    : const Icon(Icons.circle_outlined),
                              );
                            },
                            separatorBuilder: (context, i) {
                              return const Divider();
                            })
                      ])
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ));
  }
}

class NearestBusStop extends StatefulWidget {
  final LocationData location;
  NearestBusStop({Key? key, required this.location}) : super(key: key);

  @override
  State<NearestBusStop> createState() =>
      _NearestBusStopState(currentLoc: location);
}

class _NearestBusStopState extends State<NearestBusStop> {
  late LocationData currentLoc;

  // Location location = Location();
  _NearestBusStopState({required this.currentLoc});
  BusStop? nearestBusStop;
  var myLoc = Location();
  BusDataHTTP busLineHTTP = BusDataHTTP();
  @override
  void initState() {
    super.initState();
    // getNearest();
  }

  Future<BusStop> getNearest() async {
    BusStop res = BusStop(
        stationName: 'Fack',
        stationId: '',
        stationSeq: 0,
        existBus: false,
        longitude: 0,
        latitude: 0);
    await busLineHTTP.getAllBusLines();
    busLineHTTP.allBusLines.forEach((key, value) {
      value.stationList.forEach((busStop) {
        if (locDistance(currentLoc, busStop) < locDistance(currentLoc, res)) {
          res = busStop;
        }
      });
    });

    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
          future: getNearest(),
          // initialData: InitialData,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return DisplayBusStop(busStop: snapshot.data as BusStop);
            }
            return const CircularProgressIndicator();
          },
        ),
        Text(
            "${currentLoc.longitude.toString()}, ${currentLoc.latitude.toString()}"),
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
  }
}

class BusDataHTTP {
  Map<String, BusLine> allBusLines = <String, BusLine>{};
  Map<String, BusStop> allBusStops = <String, BusStop>{};

  // BusDataHTTP() {
  // generateData();
  // }

  getAllBusLines() async {
    List<dynamic> busInfos =
        json.decode(await rootBundle.loadString('lib/busLines.json'));

    // print('started');

    busInfos.forEach((busInfo) async {
      var res = await getBusLineData(busInfo['bus_id']);
      print(res.lineName);
      allBusLines[res.lineId] = res;
      // return res;
    });
  }

  Future<BusLine> getBusLineData(String busId) async {
    // print(json.decode(bus_line_id[0]));
    String bustStopUrl = '/travel/bus_line_detail/$busId/start';
    http.Response res = await http
        .post(Uri(scheme: 'https', host: 'api.u-money.mn', path: bustStopUrl));
    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      // if (body['result_code'] == "001") {
      if (body['line_name'] != null) {
        BusLine busLine = BusLine.fromJson(body);

        busLine.stationList.forEach((station) {
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

    return BusLine(lineName: '', lineId: '', stationList: []);
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
              leading: Icon(Icons.airline_stops),
              title: Text(
                busStop.stationName,
                style: const TextStyle(fontSize: 18),
              ),
              children: busStop.busLines.map<Widget>((busLine) {
                return ListTile(
                  title: Text(busLine.lineName),
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return Scaffold(
                          body: SafeArea(
                        child: ListView.separated(
                          itemCount: busLine.stationList.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider();
                          },
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                                title: Text(
                                    busLine.stationList[index].stationName),
                                trailing: busLine.stationList[index].existBus
                                    ? Icon(CupertinoIcons.bus)
                                    : Icon(Icons.arrow_downward_rounded));
                          },
                        ),
                      ));
                    }));
                  },
                );
              }).toList())
        ],
      ),
    );
  }
}

class BusLine {
  final List<BusStop> stationList;
  final String lineName;
  final String lineId;

  BusLine({
    required this.lineName,
    required this.lineId,
    required this.stationList,
  });

  factory BusLine.fromJson(Map<String, dynamic> json) {
    return BusLine(
        lineName: json['line_name'] as String,
        lineId: json['line_id'] as String,
        stationList: json['station_list'].map<BusStop>((station) {
          var busStop = BusStop.fromJson(station);
          return busStop;
        }).toList());
  }
}

class BusStop {
  final String stationName;
  final String stationId;
  final int stationSeq;
  final bool existBus;
  final double longitude;
  final double latitude;
  // BusStop? oppositeStop;
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
