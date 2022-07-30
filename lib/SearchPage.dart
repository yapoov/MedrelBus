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

class _SearchBarState extends State<SearchBar> with TickerProviderStateMixin {
  SharedPreferences sharedPreferences;
  List<BusStopModel> busStops = [];

  List<BusLineModel> busLines = [];

  int currentTabIndex = 0;
  _SearchBarState({required this.sharedPreferences});

  BusRouteFinder? busRouteFinder;

  TabController? _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);

    busRouteFinder = BusRouteFinder(sharedPreferences);
    super.initState();
    initList();
  }

  initList() async {
    BusStopDataService(sharedPreferences: await SharedPreferences.getInstance())
        .fetchAllEntries()
        .forEach((key, value) {
      setState(() {
        busStops.add(value);
      });
    });

    BusLineDataService(sharedPreferences: await SharedPreferences.getInstance())
        .fetchAllEntries()
        .forEach((key, value) {
      setState(() {
        busLines.add(value[0]);
        // busLines.add(value[1]);
      });
    });
  }

  BusStopModel topItem = BusStopModel();
  BusStopModel bottomItem = BusStopModel();

  List<BusRoute> result = [];
  @override
  Widget build(BuildContext context) {
    var routeSearch = Column(children: [
      BusStopSearchBar(topItem.stationName ?? 'хаанаас', (name) {
        setState(() {
          topItem = name;
        });
      }),
      BusStopSearchBar(bottomItem.stationName ?? 'хаашаа', (name) {
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
      Expanded(
          child: ListView(
              children: result.map<Widget>((route) {
        return ListTile(
          title: Text(route.bus!.lineName!),
        );
      }).toList()))
    ]);

    var stationSearch = Column(
      children: [
        StopSearchBar('буудал хайх', (stop) {
          setState(() {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return Scaffold(
                body: SafeArea(
                  child: BusStopDisplay(
                    busStopId: stop.stationId!,
                    sharedPrefences: sharedPreferences,
                  ),
                ),
              );
            }));
          });
        }),
      ],
    );

    var busSearch = Column(
      children: [
        BusLineSearchBar('чиглэл хайх', (line) {
          setState(() {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return Scaffold(
                body: SafeArea(
                  child: BusLineDisplay(
                    initialyExpanded: true,
                    busId: line.lineId!,
                    sharedPreferences: sharedPreferences,
                  ),
                ),
              );
            }));
          });
        }),
      ],
    );
    return Container(
      child: Column(
        children: [
          TabBar(
              labelColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.label,
              labelPadding: const EdgeInsets.only(left: 10, right: 10),
              controller: _tabController,
              onTap: (index) {
                setState(() {
                  currentTabIndex = index;
                });
              },
              tabs: const [
                Tab(text: "Маршрyт"),
                Tab(text: "Буудал"),
                Tab(text: "Чиглэл"),
              ]),
          Flexible(
            child: TabBarView(controller: _tabController, children: [
              routeSearch,
              stationSearch,
              busSearch,
            ]),
          )
        ],
      ),
    );
  }

  BusLineSearchBar(String label, Function(BusLineModel)? callback) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: GFSearchBar(
        overlaySearchListHeight: 500,
        searchBoxInputDecoration: InputDecoration(
            prefixIcon: Icon(CupertinoIcons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),

            // labelText: currentLabel
            label: Text(label)),
        searchList: busLines,
        overlaySearchListItemBuilder: (dynamic item) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              (item as BusLineModel).lineName!,
              overflow: TextOverflow.fade,
            ),
          ),
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
          if (item != null) callback!((item as BusLineModel));
        },
        noItemsFoundWidget: Container(),
      ),
    );
  }

  StopSearchBar(String label, Function(BusStopModel)? callback) {
    String currentLabel = label;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: GFSearchBar(
        overlaySearchListHeight: 500,
        searchBoxInputDecoration: InputDecoration(
            prefixIcon: Icon(CupertinoIcons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
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

  BusStopSearchBar(String label, Function(BusStopModel)? callback) {
    String currentLabel = label;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: GFSearchBar(
        searchBoxInputDecoration: InputDecoration(
            prefixIcon: Icon(CupertinoIcons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            // suffixIcon: Icon(CupertinoIcons.location),
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
