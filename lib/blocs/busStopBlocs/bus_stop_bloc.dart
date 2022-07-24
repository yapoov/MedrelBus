import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medrel_bus/blocs/busStopBlocs/bus_stop_event.dart';
import 'package:medrel_bus/blocs/busStopBlocs/bus_stop_state.dart';
import 'package:medrel_bus/bus_line_model.dart';
import 'package:medrel_bus/services/bus_stop_data_service.dart';

import 'dart:math' as Math;

class BusStopBloc extends Bloc<BusStopEvent, BusStopState> {
  BusStopDataService busStopDataService;

  BusStopBloc({required this.busStopDataService}) : super(BusStopInitial()) {
    on<UpdateBusStopEvent>(_onBusStopUpdated);
    on<GetBusStopEvent>(_OnBusStopRequested);
    on<GetNearestBusStopEvent>(_OnNearestBusStopRequested);
  }

  _onBusStopUpdated(UpdateBusStopEvent event, Emitter<BusStopState> emit) {
    return emit(BusStopUpdated(
        busStopModel: busStopDataService.updateBusStopModel(event.busStopId)));
  }

  _OnBusStopRequested(GetBusStopEvent event, Emitter<BusStopState> emit) async {
    return emit(BusStopUpdated(
        busStopModel:
            await busStopDataService.getBusStopModel(event.busStopId)));
  }

  _OnNearestBusStopRequested(
      GetNearestBusStopEvent event, Emitter<BusStopState> emit) {
    var res = BusStopModel();
    busStopDataService.fetchAllEntries().forEach((id, model) {
      if (latlongDistance(event.currentLoc,
              LatLng(model.latitude ?? 0, model.longitude ?? 0)) <
          latlongDistance(event.currentLoc,
              LatLng(res.latitude ?? 0, res.longitude ?? 0))) {
        res = model;
      }
    });
    return emit(BusStopUpdated(busStopModel: res));
  }

  double latlongDistance(LatLng A, LatLng B) {
    var p = 0.017453292519943295; // Math.PI / 180
    var c = Math.cos;
    var a = 0.5 -
        c((B.latitude - A.latitude) * p) / 2 +
        c(A.latitude * p) *
            c(B.latitude * p) *
            (1 - c((B.longitude - A.longitude) * p)) /
            2;
    return 12742 * Math.asin(Math.sqrt(a));
  }
}
