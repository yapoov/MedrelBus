import 'dart:io';

import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'busStop.dart';
// import 'userLocation.dart';
import 'SearchPage.dart';
import 'package:getwidget/getwidget.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primaryColor: Colors.redAccent,
          brightness: Brightness.light,
          appBarTheme: AppBarTheme(color: Colors.amberAccent)),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
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
