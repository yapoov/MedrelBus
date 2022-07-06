import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medrel_bus/blocs/bus_line_bloc.dart';
import 'package:medrel_bus/blocs/bus_line_event.dart';
import 'package:medrel_bus/blocs/bus_line_state.dart';
import 'package:medrel_bus/bus_line_model.dart';
import 'package:medrel_bus/services/bus_line_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BusLineDisplay extends StatefulWidget {
  SharedPreferences sharedPreferences;
  String busId;
  BusLineDisplay(
      {Key? key, required this.sharedPreferences, required this.busId})
      : super(key: key);

  @override
  State<BusLineDisplay> createState() => _BusLineDisplayState(
      sharedPreferences: sharedPreferences, busLineId: busId);
}

class _BusLineDisplayState extends State<BusLineDisplay> {
  final String busLineId;
  final SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
  }

  _BusLineDisplayState(
      {required this.busLineId, required this.sharedPreferences});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        var bloc = BusLineBloc(
            busLineDataService:
                BusLineDataService(sharedPreferences: sharedPreferences));
        bloc.add(UpdateBusLine(busId: busLineId));
        return bloc;
      },
      child: BlocBuilder<BusLineBloc, BusLineState>(
        builder: (context, busLineState) {
          if (busLineState.busLineModels[0].stationList != null) {
            var startLine = busLineState.busLineModels[0];
            var endLine = busLineState.busLineModels[1];
            return Card(
              shape: const BeveledRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),

              child: ExpansionTile(
                title: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    startLine.lineName!,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              // child: ExpansionPanelList(
              //   expansionCallback: (int index, bool expanded) {
              //     expanded = !expanded;
              //   },
              //   children: busLineState.busLineModels[1].stationList
              //           ?.map<ExpansionPanel>((station) {
              //         return ExpansionPanel(

              //             headerBuilder: (context, isExpanded) {
              //               return ListTile(
              //                 title: Text(station.stationName!),
              //                 trailing: station.existBus!
              //                     ? Icon(CupertinoIcons.bus)
              //                     : Icon(CupertinoIcons.arrow_down),
              //               );
              //             },
              //             body: ListTile(
              //               title: Text(
              //                   'daraachiin avtuus irehed x min'), //TODO : bus prediction
              //             ));
              //       }).toList() ??
              //       [],
              // ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
