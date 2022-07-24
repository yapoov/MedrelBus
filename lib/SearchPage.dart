import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medrel_bus/bus_line_display.dart';
import 'package:medrel_bus/bus_line_model.dart';
import 'package:medrel_bus/bus_stop_display.dart';
import 'package:medrel_bus/services/bus_line_data_service.dart';
import 'package:medrel_bus/services/bus_route_finder.dart';

import 'package:medrel_bus/services/bus_stop_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timelines/timelines.dart';

class SearchPage extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  const SearchPage({Key? key, required this.sharedPreferences})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
              padding: EdgeInsets.all(30),
              child: SearchBar(
                sharedPreferences: sharedPreferences,
              ))),
    );
  }
}

class SearchBar extends StatefulWidget {
  SharedPreferences sharedPreferences;
  SearchBar({Key? key, required this.sharedPreferences}) : super(key: key);

  @override
  State<SearchBar> createState() =>
      _SearchBarState(sharedPreferences: sharedPreferences);
}

class _SearchBarState extends State<SearchBar> {
  SharedPreferences sharedPreferences;
  List<BusStopModel> busStops = [];
  _SearchBarState({required this.sharedPreferences});

  BusRouteFinder? busRouteFinder;
  @override
  void initState() {
    // TODO: implement initState

    busRouteFinder = BusRouteFinder(sharedPreferences);
    super.initState();
    initList();
  }

  initList() async {
    BusStopDataService(sharedPreferences: await SharedPreferences.getInstance())
        .fetchAllEntries()
        .forEach((key, value) {
      setState(() {
        if (value != null) busStops.add(value);
      });
    });
  }

  BusStopModel topItem = BusStopModel();
  BusStopModel bottomItem = BusStopModel();

  List<BusRoute> result = [];
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SearchBar(topItem.stationName ?? 'Хаанаас', (name) {
        setState(() {
          topItem = name;
        });
      }),
      SearchBar(bottomItem.stationName ?? 'Хаашаа', (name) {
        setState(() {
          bottomItem = name;
        });
      }),
      ListTile(
        title: ElevatedButton(
            onPressed: () {
              setState(() {
                result = busRouteFinder?.SearchRoute(topItem, bottomItem) ?? [];
              });
            },
            child: const Text(
              'Хайх',
              style: TextStyle(fontSize: 20),
            )),
      ),
      //show Results
      Text('Results'),
      Expanded(
          child: ListView(
              children: result.map<Widget>((route) {
        return ListTile(
          title: Text(route.bus!.lineName!),
        );
      }).toList()))
    ]);
  }

  SearchBar(String label, Function(BusStopModel)? callback) {
    String currentLabel = label;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: GFSearchBar(
        searchBoxInputDecoration: InputDecoration(
            prefixIcon: Icon(CupertinoIcons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            suffixIcon: Icon(CupertinoIcons.location),
            // labelText: currentLabel
            label: Text(currentLabel)),
        searchList: busStops,
        overlaySearchListItemBuilder: (dynamic item) => ListTile(
          title: Text((item as BusStopModel).stationName!),
        ),
        searchQueryBuilder: (query, list) => list.where((item) {
          query = query.toLowerCase();
          query = query.replaceAllMapped(
              RegExp(r'\w+'), (match) => LatinToCyrillic(match[0]!));

          var hashMap = {'о': 'ө', 'у': 'ү'};
          return item.toString().toLowerCase().contains(query) ||
              item.toString().toLowerCase().contains(query.replaceAllMapped(
                  RegExp(r'о|у'), (match) => hashMap[match[0]]!));
        }).toList(),
        onItemSelected: (dynamic item) {
          if (item != null) callback!((item as BusStopModel));
        },
        noItemsFoundWidget: Container(),
      ),
    );
  }

  String LatinToCyrillic(String input) {
    Map<String, String> hashMap = {
      'a': 'а',
      'b': 'б',
      'c': 'ц',
      'd': 'д',
      'e': 'э',
      'f': 'ф',
      'g': 'г',
      'h': 'х',
      'i': 'и',
      'j': 'ж',
      'k': 'к',
      'l': 'л',
      'm': 'м',
      'n': 'н',
      'o': 'о',
      'p': 'п',
      'q': 'ө',
      'r': 'р',
      's': 'с',
      't': 'т',
      'v': 'в',
      'u': 'у',
      'w': 'в',
      'x': 'х',
      'y': 'ы',
      'z': 'з',
      'ch': 'ч',
      'sh': 'ш',
      'ya': 'я',
      'ye': 'е',
      'yu': 'ю',
      'ai': 'ай',
      'ei': 'эй',
      'oi': 'ой',
      'ui': 'уй',
    };
    input = input.replaceAllMapped(RegExp(r'ch|sh|ya|ye|yu|ai|ei|oi|ui'),
        (match) => hashMap[match[0]] ?? '');
    return input.replaceAllMapped(
        RegExp(r'\w'), (match) => hashMap[match[0]] ?? '');
  }
}






// type '(String, List<BusStopModel>) => List<BusStopModel>' is not a subtype of type '(String, List<BusStopModel?>) => List<BusStopModel?>'