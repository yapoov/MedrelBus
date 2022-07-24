import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/retry.dart';
import 'package:medrel_bus/bus_line_model.dart';
import 'package:medrel_bus/services/bus_line_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BusStopDataService {
  static const String _sharedPreferenceKey = 'bus_stop_data';

  SharedPreferences sharedPreferences;
  late BusLineDataService busLineDataService;
  BusStopDataService({required this.sharedPreferences}) {
    busLineDataService =
        BusLineDataService(sharedPreferences: sharedPreferences);
  }

  Map<String, BusStopModel> fetchAllEntries() {
    final Map<String, BusStopModel> result = {};
    if (!sharedPreferences.containsKey(_sharedPreferenceKey)) return {};

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
      result[key] = BusStopModel.fromJson(value);
    });
    // for (final dynamic entry in values) {
    //   result.add(BusStopModel.fromJson(entry as Map<String, dynamic>));
    // }
    return result;
  }

  Future<bool> updateEntries() async {
    bool result = true;
    return await busLineDataService.updateEnries().then((res) {
      if (res) {
        busLineDataService.fetchAllEntries().forEach((busId, busLines) {
          busLines.forEach((busLine) {
            if (busLine.stationList != null) {
              busLine.stationList!.forEach((station) async {
                bool isSuccesful = await addEntry(station);
                // print(fetchAllEntries().length);
                if (!isSuccesful) result = false;
              });
            }
          });
        });
      }
    }).then((value) {
      return result;
    });
  }

  Future<bool> addEntry(BusStopModel model) async {
    final Map<String, BusStopModel> allEntries = fetchAllEntries();
    if (model.stationId != null) {
      allEntries[model.stationId!] = model;
    }

    return sharedPreferences.setString(
        _sharedPreferenceKey, jsonEncode(allEntries));
  }

  Future<BusStopModel> getBusStopModel(String busStopId) async {
    var allEntries = fetchAllEntries();

    var res = BusStopModel();

    if (allEntries[busStopId] == null) {
      await updateEntries().then((isSuccesful) {
        if (isSuccesful) res = allEntries[busStopId] ?? BusStopModel();
      });
    } else {
      res = allEntries[busStopId]!;
    }
    return res;
  }

  List<BusLineModel> getBusStopRoutes(String busStopId) {
    var allEntries = busLineDataService.fetchAllEntries();
    List<BusLineModel> res = [];
    allEntries.forEach((key, busLines) {
      busLines.forEach((busline) {
        busline.stationList!.forEach((station) {
          if (station.stationId == busStopId) {
            res.add(busline);
          }
        });
      });
    });
    return res;
  }

  updateBusStopModel(String busStopId) async {}
}
