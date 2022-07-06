import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(padding: EdgeInsets.all(30), child: SearchBar())),
    );
  }
}

class SearchBar extends StatefulWidget {
  SearchBar({Key? key}) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

List list = [
  'flutter',
  'angular',
  'node js',
  'aa',
  'bb',
  'd',
  'e',
  'asdsadasd'
];

class _SearchBarState extends State<SearchBar> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var SearchBarTop = GFSearchBar(
      searchBoxInputDecoration: InputDecoration(
        suffixIcon: Icon(CupertinoIcons.location),
      ),
      searchList: list,
      overlaySearchListItemBuilder: (dynamic item) => Container(
        padding: const EdgeInsets.all(8),
        child: Text(
          item,
          style: const TextStyle(fontSize: 18),
        ),
      ),
      searchQueryBuilder: (query, list) => list.where((item) {
        return item!.toString().toLowerCase().contains(query.toLowerCase());
      }).toList(),
      onItemSelected: (dynamic item) {
        setState(() {});
      },
    );

    var SearchBarBottom = GFSearchBar(
      searchBoxInputDecoration: InputDecoration(
        suffixIcon: Icon(CupertinoIcons.search),
      ),
      searchList: list,
      overlaySearchListItemBuilder: (dynamic item) => Container(
        padding: const EdgeInsets.all(8),
        child: Text(
          item,
          style: const TextStyle(fontSize: 18),
        ),
      ),
      searchQueryBuilder: (query, list) => list.where((item) {
        return item!.toString().toLowerCase().contains(query.toLowerCase());
      }).toList(),
      onItemSelected: (dynamic item) {
        setState(() {});
      },
    );

    return Column(
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Хаанаас',
              style: TextStyle(fontSize: 20),
            )),
        SearchBarTop,
        Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Хаашаа',
              style: TextStyle(fontSize: 20),
            )),
        SearchBarBottom,
        ElevatedButton(
            onPressed: () {},
            child: Text(
              'Хайх',
              style: TextStyle(fontSize: 20),
            ))
      ],
    );
  }
}
