import 'dart:ffi';

import "package:flutter/material.dart";
import 'busStop.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.orangeAccent),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const ListTile(
            title: Text("Medrel bus",
                style: TextStyle(
                    fontFamily: 'helvetica standard',
                    fontSize: 20,
                    color: Colors.white)),
            leading: Icon(Icons.car_rental),
          ),
        ),
        drawer: MyDrawer(),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'search'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'map'),
          ],
        ),
        body: Container(
          child: BusLineDisplay(),
          padding: EdgeInsets.all(10),
        ));
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
        DrawerHeader(child: Text("Header")),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () {},
        )
      ],
    ));
  }
}
