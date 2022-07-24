import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medrel_bus/blocs/bus_line_bloc.dart';
import 'package:medrel_bus/blocs/bus_line_event.dart';
import 'package:medrel_bus/blocs/bus_line_state.dart';
import 'package:medrel_bus/bus_line_model.dart';
import 'package:medrel_bus/services/bus_line_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bus_stop_display.dart';
// import 'package:getwidget/getwidget.dart';
import 'package:timelines/timelines.dart';

class BusLineDisplay extends StatefulWidget {
  SharedPreferences sharedPreferences;
  String busId;
  bool? initialyExpanded;
  BusLineDisplay(
      {Key? key,
      required this.sharedPreferences,
      required this.busId,
      this.initialyExpanded})
      : super(key: key);

  @override
  State<BusLineDisplay> createState() => _BusLineDisplayState(
      sharedPreferences: sharedPreferences, busLineId: busId);
}

class _BusLineDisplayState extends State<BusLineDisplay> {
  final String busLineId;
  final SharedPreferences sharedPreferences;
  bool? initialyEpxanded;
  bool expandedFlag = false;
  // bool showEndLineFlag = false;
  List<bool> isSelected = [true, false];
  @override
  void initState() {
    super.initState();
  }

  _BusLineDisplayState(
      {required this.busLineId,
      required this.sharedPreferences,
      this.initialyEpxanded});
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
              shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: ExpansionTile(
                initiallyExpanded: initialyEpxanded ?? false,
                title: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    startLine.lineName!,
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    child: LayoutBuilder(builder: (context, constraints) {
                      return ToggleButtons(
                        borderRadius: BorderRadius.circular(5),
                        // renderBorder: false,
                        constraints: BoxConstraints.expand(
                          width: constraints.maxWidth / 2 - 10,
                        ),
                        isSelected: isSelected,
                        children: [
                          BusDirectionToggle('Эхлэх цэг',
                              '${startLine.startTimeAtStartPoint}~${startLine.endTimeAtStartPoint}'),
                          BusDirectionToggle('Эцсийн цэг',
                              '${endLine.startTimeAtEndPoint}~${endLine.endTimeAtEndPoint}')
                        ],
                        onPressed: (int index) {
                          setState(() {
                            for (var i = 0; i < isSelected.length; i++) {
                              isSelected[i] = false;
                            }
                            isSelected[index] = true;
                          });
                        },
                      );
                    }),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                        'Автобус хоорондын зай: ${DateTime.now().weekday <= 5 ? startLine.weekdayInterval : startLine.holidayInterval} мин'),
                  ),
                  const Divider(
                    endIndent: 10,
                    indent: 10,
                    thickness: 2,
                  ),
                  ExpandableContainer(
                    expandedHeight: 300,
                    expanded: true,
                    child: isSelected[0]
                        ? DisplayStopsTimeLine(startLine)
                        : DisplayStopsTimeLine(endLine),
                  ),
                ],
              ),
            );
          }
          return const Card(
              child: ListTile(
                  title: LinearProgressIndicator(
            minHeight: 15,
            backgroundColor: Color.fromARGB(255, 211, 211, 211),
            color: Color.fromARGB(255, 215, 215, 215),
          )));
        },
      ),
    );
  }

  Padding BusDirectionToggle(String text, String subTitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: ListTile(
        style: ListTileStyle.drawer,
        title: Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
        subtitle: Row(
          children: [
            const Icon(
              CupertinoIcons.time,
              size: 15,
            ),
            Text('  $subTitle'),
          ],
        ),
      ),
    );
  }

  DisplayStopsTimeLine(BusLineModel busLine) {
    return Timeline.tileBuilder(
        controller: TrackingScrollController(),
        theme: TimelineThemeData(color: Colors.grey),
        builder: TimelineTileBuilder.connected(
            connectorBuilder: (context, index, type) {
              return Connector.solidLine();
            },
            indicatorBuilder: (_, index) {
              if (busLine.stationList![index].existBus!) {
                return Indicator.outlined(
                  size: 15,
                  child: Icon(
                    CupertinoIcons.bus,
                    size: 20,
                  ),
                );
              }
              return Indicator.outlined(
                size: 15,
              );
            },
            nodePositionBuilder: (context, index) {
              return 0.05;
            },
            contentsBuilder: (context, index) {
              return ListTile(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return SafeArea(
                        child: BusStopDisplay(
                            busStopId: busLine.stationList![index].stationId!,
                            sharedPrefences: sharedPreferences),
                      );
                    }));
                  },
                  title: Text(busLine.stationList![index].stationName!));
            },
            itemCount: busLine.stationList!.length));
  }

  ListView DisplayStops(BusLineModel startLine) {
    return ListView.separated(
      itemCount: startLine.stationList!.length,
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(
          endIndent: 20,
          indent: 20,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        // return Timeline.builder(itemBuilder: itemBuilder, itemCount: itemCount)
        return ListTile(
            trailing: TimelineNode.simple(),
            title: Text(startLine.stationList![index].stationName!));
      },
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
