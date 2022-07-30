import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medrel_bus/blocs/busStopBlocs/bus_stop_bloc.dart';
import 'package:medrel_bus/blocs/busStopBlocs/bus_stop_event.dart';
import 'package:medrel_bus/blocs/busStopBlocs/bus_stop_state.dart';
import 'package:medrel_bus/bus_line_model.dart';
import 'package:medrel_bus/bus_stop_display.dart';
import 'package:medrel_bus/services/bus_stop_data_service.dart';
import 'package:medrel_bus/userLocation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NearestStop extends StatelessWidget {
  NearestStop({Key? key, required this.sharedPreferences}) : super(key: key);

  SharedPreferences sharedPreferences;

  CurrentLocation currentLocation = CurrentLocation();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        var bloc = BusStopBloc(
            busStopDataService:
                BusStopDataService(sharedPreferences: sharedPreferences));
        bloc.add(GetNearestBusStopEvent());
        return bloc;
      },
      child: BlocBuilder<BusStopBloc, BusStopState>(
          builder: (context, busStopState) {
        if (busStopState.busStopModel.stationId != null) {
          return BusStopDisplay(
              busStopId: busStopState.busStopModel.stationId!,
              sharedPrefences: sharedPreferences);
        }
        return const Card(
          child: LinearProgressIndicator(),
        );
      }),
    );
  }
}
