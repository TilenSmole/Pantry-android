import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class Recepies extends StatefulWidget  {

  @override
  _RecepiesState createState() => _RecepiesState();
}


class _RecepiesState extends State<Recepies> {
  List _items = [];

   @override
  void initState() {
    super.initState();
    readJson();
  }

  Future<void> readJson() async {
    try {
      // Load the JSON file from assets
    final String response = await rootBundle.loadString('RECIPES/recipes.json');

      // Decode the JSON data
      final data = json.decode(response);
      print('JSON Data: data');

      // Update the state with the data
      setState(() {
        _items = data["recepies"];
      });

      // Print the data to the console
      print('JSON Data: $_items');
    } catch (e) {
      print('Error loading JSON data: $e');
    }
  }




  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      children: <Widget>[
        Card(child: Center(child: Text('Item 1'))),
        Card(child: Center(child: Text('Item 2'))),
        Card(child: Center(child: Text('Item 3'))),
        Card(child: Center(child: Text('Item 4'))),
      ],
    );
  }
}
