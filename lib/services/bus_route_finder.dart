import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bus_line_model.dart';
import 'bus_line_data_service.dart';
import 'bus_stop_data_service.dart';

//TODO:deed
class BusRoute {
  BusStopModel? start;
  BusLineModel? bus;
  BusStopModel? end;
  BusRoute({this.start, this.bus, this.end});
}

class BusRouteFinder {
  late BusStopDataService busStopDataService;
  late BusLineDataService busLineDataService;

  BusRouteFinder(SharedPreferences sharedPreferences) {
    busLineDataService =
        BusLineDataService(sharedPreferences: sharedPreferences);
    busStopDataService =
        BusStopDataService(sharedPreferences: sharedPreferences);
  }

  List<BusRoute> SearchRoute(BusStopModel start, BusStopModel target) {
    List<BusRoute> res = [];

    Map<BusStopModel, List<BusLineModel>> toRoutes = {};

    Map<BusStopModel, BusStopModel> oppositeStopMap = {};

    //generating oppositeStopMap
    busLineDataService.fetchAllEntries().forEach((key, busLines) {
      var startLine = busLines[0];
      var endLine = busLines[1];
      if (startLine.stationList!.length == endLine.stationList!.length) {
        int len = startLine.stationList!.length;
        for (var i = 0; i < len; i++) {
          oppositeStopMap[startLine.stationList![i]] =
              endLine.stationList![len - i - 1];
          oppositeStopMap[endLine.stationList![len - i - 1]] =
              startLine.stationList![i];
        }
      }
    });

    //genereating stop to bus hashmap
    busLineDataService.fetchAllEntries().forEach((key, busLines) {
      var startLine = busLines[0];
      var endLine = busLines[1];

      if (startLine.stationList == null || endLine.stationList == null) {
        return;
      }
      for (var station in startLine.stationList!) {
        if (toRoutes.containsKey(station)) {
          toRoutes[station]!.addAll([startLine, endLine]);
        } else {
          toRoutes[station] = [startLine, endLine];
        }
      }

      for (var station in endLine.stationList!) {
        if (toRoutes.containsKey(station)) {
          toRoutes[station]!.addAll([startLine, endLine]);
        } else {
          toRoutes[station] = [startLine, endLine];
        }
      }
    });

    Set<BusLineModel> visited = <BusLineModel>{};

    Queue<BusStopModel> queue = Queue();
    queue.add(start);
    int numOfRoutes = 0;
    while (queue.isNotEmpty) {
      int preNumStops = queue.length;
      numOfRoutes++;
      for (int i = 0; i < preNumStops; i++) {
        var currentStop = queue.removeFirst();

        for (var bus in toRoutes[currentStop] ?? []) {
          if (!visited.contains(bus)) {
            visited.add(bus);
            for (var stop in bus.stationList!) {
              if (stop == target || stop == oppositeStopMap[target]) {
                res.add(BusRoute(
                  start: currentStop,
                  bus: bus,
                  end: stop,
                ));

                return res;
              }
              queue.add(stop);
            }
          }
        }
      }
    }
    return [];
  }
}
