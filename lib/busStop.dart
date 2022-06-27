import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BusLineDisplay extends StatefulWidget {
  BusLineDisplay({Key? key}) : super(key: key);

  @override
  State<BusLineDisplay> createState() => _BusStopState();
}

class _BusStopState extends State<BusLineDisplay> {
  @override
  Widget build(BuildContext context) {
    final HTTPSservice httpSservice = HTTPSservice();

    return Card(
        shape: BeveledRectangleBorder(borderRadius: BorderRadius.horizontal()),
        child: FutureBuilder(
          future: httpSservice.getPosts(),
          builder: (context, AsyncSnapshot<BusLine> snapshot) {
            if (snapshot.hasData) {
              BusLine? busLine = snapshot.data;
              return ListView.separated(
                itemCount: busLine!.station_list.length,
                separatorBuilder: (context, index) {
                  return const Divider(
                    height: 1,
                  );
                },
                itemBuilder: (context, index) {
                  BusStation station = busLine.station_list[index];
                  return ListTile(
                    title: Text(station!.station_name),
                    trailing: station.exist_bus
                        ? Icon(Icons.bus_alert)
                        : Icon(Icons.circle),
                  );
                },
              );
            } else {
              return Center(child: CircularProgressIndicator());
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
