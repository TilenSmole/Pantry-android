import 'dart:async';
import 'package:flutter/material.dart';
import './API/warnings.dart' as API;

class Warnings extends StatefulWidget {
  @override
  _WarningsState createState() => _WarningsState();
}

class _WarningsState extends State<Warnings> {
  String? token;
  Map<int, String> _storage = {};
  List<dynamic> warnings = [];

  Map<int, bool> taskSelection = {};
  bool enableOnlyStorageSaving = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    List<dynamic> warningsFetched = await API.getWarnings();

    setState(() {
      warnings = warningsFetched;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WARNINGS'),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
            children: warnings.map((warning) {
          return Text(
              "-> ${warning["amount"]} grams of ${warning["ingredient"]} left", style: TextStyle(fontSize: 17.0)) ;
        }).toList()),
      ),
    );
  }
}
