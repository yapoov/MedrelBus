import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medrel_bus/blocs/busStopBlocs/bus_stop_bloc.dart';
import 'package:medrel_bus/blocs/busStopBlocs/bus_stop_event.dart';
import 'package:medrel_bus/blocs/busStopBlocs/bus_stop_state.dart';
import 'package:medrel_bus/bus_line_display.dart';
import 'package:medrel_bus/bus_line_model.dart';
import 'package:medrel_bus/services/bus_stop_data_service.dart';
import 'package:medrel_bus/userLocation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BusStopDisplay extends StatefulWidget {
  String busStopId;
  SharedPreferences sharedPrefences;

  BusStopDisplay(
      {Key? key, required this.busStopId, required this.sharedPrefences})
      : super(key: key);

  @override
  State<BusStopDisplay> createState() => _BusStopDisplayState(
      busStopId: busStopId, sharedPrefences: sharedPrefences);
}

class _BusStopDisplayState extends State<BusStopDisplay> {
  String busStopId;
  // SharedPrefences sharedPrefences;
  SharedPreferences sharedPrefences;

  _BusStopDisplayState(
      {required this.busStopId, required this.sharedPrefences});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        var bloc = BusStopBloc(
            busStopDataService:
                BusStopDataService(sharedPreferences: sharedPrefences));
        bloc.add(GetBusStopEvent(busStopId: busStopId));
        return bloc;
      },
      child: BlocBuilder<BusStopBloc, BusStopState>(
        builder: (context, busStopState) {
          if (busStopState.busStopModel.stationId != null) {
            BusStopModel busStopModel = busStopState.busStopModel;
            return Card(
                shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: ExpansionTile(
                  title: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      busStopModel.stationName!,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  onExpansionChanged: (changed) {},
                  children: [
                    const Divider(
                      endIndent: 10,
                      indent: 10,
                      thickness: 2,
                    ),
                    ExpandableContainer(
                      expanded: true,
                      expandedHeight: 300,
                      child: ListView.separated(
                        itemCount: BusStopDataService(
                                sharedPreferences: sharedPrefences)
                            .getBusStopRoutes(busStopModel.stationId!)
                            .length,
                        separatorBuilder: (BuildContext context, int index) {
                          return const Divider();
                        },
                        itemBuilder: (BuildContext context, int index) {
                          var busLine = BusStopDataService(
                                  sharedPreferences: sharedPrefences)
                              .getBusStopRoutes(busStopModel.stationId!)[index];

                          return ListTile(
                            title: Text(busLine.lineName!),
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return SafeArea(
                                  child: BusLineDisplay(
                                      initialyExpanded: true,
                                      sharedPreferences: sharedPrefences,
                                      busId: busLine.lineId!),
                                );
                              }));
                            },
                          );
                        },
                      ),
                    )
                  ],
                ));
          }
          return const Card(
              child: ListTile(
            // title: Text(''),
            title: LinearProgressIndicator(
              minHeight: 15,
              backgroundColor: Color.fromARGB(255, 211, 211, 211),
              color: Color.fromARGB(255, 215, 215, 215),
            ),
          ));
        },
      ),
    );
  }
}

class ExpandableContainer extends StatelessWidget {
  const ExpandableContainer(
      {Key? key,
      this.expanded = true,
      this.collapsedHeight = 100.0,
      this.expandedHeight = 300.0,
      required this.child})
      : super(key: key);
  final bool expanded;
  final double collapsedHeight;
  final double expandedHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return AnimatedContainer(
      duration: Duration(microseconds: 500),
      curve: Curves.bounceInOut,
      width: screenWidth,
      height: expanded ? expandedHeight : collapsedHeight,
      child: Container(
        child: child,
        // decoration: BoxDecoration(border: Border.all(width: 1)),
      ),
    );
  }
}
