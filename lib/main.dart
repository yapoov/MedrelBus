import 'dart:ffi';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';
import 'package:medrel_bus/blocs/busStopBlocs/bus_stop_bloc.dart';
import 'package:medrel_bus/bus_line_display.dart';
import 'package:medrel_bus/bus_stop_display.dart';
import 'package:medrel_bus/map_screen.dart';
import 'package:medrel_bus/nearest_stop.dart';
import 'package:medrel_bus/services/bus_line_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'userLocation.dart';
import 'SearchPage.dart';
import 'package:getwidget/getwidget.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'map_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();

  // sharedPreferences.clear();
  runApp(MyApp(sharedPreferences: sharedPreferences));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  const MyApp({super.key, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primaryColor: Colors.redAccent,
          brightness: Brightness.light,
          appBarTheme: AppBarTheme(color: Color.fromARGB(255, 254, 144, 0))),
      home: MyHomePage(
        sharedPreferences: sharedPreferences,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  SharedPreferences sharedPreferences;
  MyHomePage({Key? key, required this.sharedPreferences}) : super(key: key);

  @override
  State<MyHomePage> createState() =>
      _MyHomePageState(sharedPreferences: sharedPreferences);
}

class _MyHomePageState extends State<MyHomePage> {
  SharedPreferences sharedPreferences;
  _MyHomePageState({required this.sharedPreferences});

  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    var tabs = [
      ListView(children: [
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            'Ойрхон буудал',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: NearestStop(sharedPreferences: sharedPreferences),
        ),
      ]),
      SearchPage(sharedPreferences: sharedPreferences),
      MapScreen()
    ];
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
            title: Row(
          children: const [
            Icon(
              CupertinoIcons.bus,
              size: 40,
            ),
            Text("Medrel bus",
                style: TextStyle(
                    fontFamily: 'Calibri',
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ],
        )),
      ),
      drawer: MyDrawer(),
      body: tabs[currentIndex],
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'нүүр'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'хайлт'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'газрын зураг'),
        ],
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          child: Text(''),
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () {},
        )
      ],
    ));
  }
}
