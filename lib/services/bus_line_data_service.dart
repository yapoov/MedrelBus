import 'dart:convert';
import 'dart:ffi';

import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:medrel_bus/bus_line_model.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class BusLineDataService {
  static String _sharedPreferenceKey = 'bus_line_data';

  SharedPreferences sharedPreferences;
  BusLineHTTP busLineHTTP = BusLineHTTP();
  BusLineDataService({required this.sharedPreferences});

  Map<String, List<BusLineModel>> fetchAllEntries() {
    final Map<String, List<BusLineModel>> result = {};

    if (!sharedPreferences.containsKey(_sharedPreferenceKey)) {
      return {};
    }

    Map<String, dynamic> values = {};
    try {
      final String? storedValue =
          sharedPreferences.getString(_sharedPreferenceKey);

      if (storedValue == null) {
        return {};
      }

      values = jsonDecode(storedValue) as Map<String, dynamic>;
    } on FormatException {
      sharedPreferences.remove(_sharedPreferenceKey);
    }

    values.forEach((key, value) {
      var val = value as List<dynamic>;

      result[key] = val.map((e) => BusLineModel.fromJson(e)).toList();
    });
    return result;
  }

  Future<bool> addEntry(BusLineModel modelStart, BusLineModel modelEnd) async {
    final Map<String, List<BusLineModel>> allEntries = fetchAllEntries();
    if (modelEnd.lineId == null || modelStart.lineId == null) return false;

    allEntries[modelStart.lineId!] = [modelStart, modelEnd];
    return sharedPreferences.setString(
        _sharedPreferenceKey, jsonEncode(allEntries));
  }

  Future<List<BusLineModel>> updateEntry(String busId) async {
    var startLine = await busLineHTTP.getBusLine(busId, true);
    var endLine = await busLineHTTP.getBusLine(busId, false);
    await addEntry(startLine, endLine);
    return [startLine, endLine];
  }

  Future<bool> updateEnries() async {
    var ids = await busLineHTTP.getAllBuslineIds();
    var res = true;

    ids.forEach((id) async {
      var busLineStart = await busLineHTTP.getBusLine(id, true);
      var busLineEnd = await busLineHTTP.getBusLine(id, false);
      // print(busLineStart.lineName);
      await addEntry(busLineStart, busLineEnd);

      print('bus entry length: ${fetchAllEntries().length}');
    });
    return res;
  }
}

class BusLineHTTP {
  Future<List<String>> getAllBuslineIds() async {
    List<dynamic> busInfos =
        json.decode(await rootBundle.loadString('lib/busLines.json'));

    var res = busInfos.map((e) {
      return e['bus_id'] as String;
    }).toList();
    return res;
  }

  Future<BusLineModel> getBusLine(String busId, bool isStart) async {
    String bustStopUrl =
        '/travel/bus_line_detail/$busId/${isStart ? 'start' : 'end'}';
    http.Response res = await http
        .post(Uri(scheme: 'https', host: 'api.u-money.mn', path: bustStopUrl));

    if (res.statusCode == 200) {
      var json = jsonDecode(res.body);
      if (json['result_code'] == '001') {
        if (json['line_name'] == null) return BusLineModel();

        BusLineModel busLineModel = BusLineModel(
            lineName: json['line_name'] as String,
            lineId: json['line_id'] as String,
            stationList: json['station_list'].map<BusStopModel>((station) {
              var busStop = BusStopModel.fromJson(station);
              return busStop;
            }).toList(),
            isStartDirection: isStart,
            weekdayInterval: json['weekday_interval'] as int,
            holidayInterval: json['holiday_interval'] as int,
            startTimeAtStartPoint: json['start_time_at_start_point'] as String,
            startTimeAtEndPoint: json['start_time_at_end_point'] as String,
            endTimeAtStartPoint: json['end_time_at_start_point'] as String,
            endTimeAtEndPoint: json['end_time_at_end_point'] as String);

        return busLineModel;
      }
    }

    return BusLineModel();
  }
}
