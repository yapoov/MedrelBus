import 'dart:async';
// import 'dart:html';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medrel_bus/blocs/bus_line_event.dart';
import 'package:medrel_bus/blocs/bus_line_state.dart';
import 'package:medrel_bus/services/bus_line_data_service.dart';

class BusLineBloc extends Bloc<BusLineEvent, BusLineState> {
  BusLineBloc({required this.busLineDataService}) : super(BusLineInitial()) {
    on<UpdateBusLine>(_onBusLineUpdated);
  }

  BusLineDataService busLineDataService;

  _onBusLineUpdated(UpdateBusLine event, Emitter<BusLineState> emit) async {
    return emit(BusLineChanged(
        busLineModels: await busLineDataService.updateEntry(event.busId)));
  }
}
