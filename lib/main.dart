import 'dart:ffi';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:location/location.dart';
import 'package:medrel_bus/bus_line_display.dart';
import 'package:medrel_bus/services/bus_line_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'userLocation.dart';
import 'SearchPage.dart';
import 'package:getwidget/getwidget.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();

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
          appBarTheme: AppBarTheme(color: Colors.amberAccent)),
      home: MyHomePage(
        sharedPreferences: sharedPreferences,
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  MyHomePage({required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    var home = Scaffold(
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
      body: Column(children: [
        const Text(
          'Favorites',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        BusLineDisplay(busId: '11100171', sharedPreferences: sharedPreferences)
      ]),
    );
    return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'search'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'map'),
        ]),
        tabBuilder: (context, index) {
          switch (index) {
            case 0:
              return home;
            case 1:
              return const SearchPage();
            case 2:
              return Container(); //TODO map hiine
            default:
              return home;
          }
        });
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
