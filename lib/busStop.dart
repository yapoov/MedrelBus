import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';

class BusLineDisplay extends StatefulWidget {
  BusLineDisplay({Key? key}) : super(key: key);

  @override
  State<BusLineDisplay> createState() => _BusStopState();
}

class _BusStopState extends State<BusLineDisplay> {
  bool _tileExpanded = false;
  @override
  Widget build(BuildContext context) {
    final HTTPSservice httpSservice = HTTPSservice();

    return Card(
        shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: FutureBuilder(
          future: httpSservice.getPosts(),
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
                                      busLine!.station_list[i].station_name),
                                  trailing: busLine!.station_list[i].exist_bus
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

class HTTPSservice {
  final String bustStopUrl = "/travel/bus_line_detail/11100070/start";

  Future<BusLine> getPosts() async {
    http.Response res = await http
        .post(Uri(scheme: 'https', host: 'api.u-money.mn', path: bustStopUrl));
    if (res.statusCode == 200) {
      BusLine busLine = BusLine.fromJson(jsonDecode(res.body));

      return busLine;
    } else {
      throw "unable to retrieve stops";
    }
  }
}

class BusLine {
  final List<BusStation> station_list;
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
        station_list: json['station_list'].map<BusStation>((station) {
          return BusStation.fromJson(station);
        }).toList());
  }
}

class BusStation {
  final String station_name;
  final String station_id;
  final int station_seq;
  final bool exist_bus;
  final double longitude;
  final double latitude;

  BusStation(
      {required this.station_name,
      required this.station_id,
      required this.station_seq,
      required this.exist_bus,
      required this.longitude,
      required this.latitude});

  factory BusStation.fromJson(Map<String, dynamic> json) {
    return BusStation(
        station_id: json['station_id'] as String,
        station_name: json['station_name'] as String,
        station_seq: json['station_seq'] as int,
        exist_bus: json['exist_bus'] == 'Y',
        longitude: json['longitude'] as double,
        latitude: json['latitude'] as double);
  }
}
