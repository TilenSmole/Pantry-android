import 'package:flutter/material.dart';
import './Components/load_token.dart' as load_token;
import 'login.dart';
import './Components/logout.dart';
import 'dart:async';
import 'Components/PROFILE/notes.dart';
import 'Components/OTHER/item_add.dart';
import 'Components/OTHER/filter_storage.dart';
import 'Components/OTHER/warnings.dart';
import 'Components/PROFILE/weekly.dart';
import 'colors.dart';
import 'Components/PROFILE/analyser.dart';
import 'Components/OTHER/API/warnings.dart' as WARNINGS_API;

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? token;
  Map<String, dynamic> _user = {};
  List<dynamic> warnings = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedToken = await load_token.loadToken();
    List<dynamic> warningsFetched = await WARNINGS_API.getWarnings();

    setState(() {
      token = loadedToken;
      warnings = warningsFetched;
    });
    if (token != null) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        
        children: [
          Center(
            child: token != null
                ? Column(children: [
                    Padding(padding:  const EdgeInsets.only(top:40.0),),
                    Text(
                        'WELCOME: ${token == null ? "loading" : _user["id"].toString()} !',
                        style: TextStyle(fontSize: 24), ),
                  ])
                : Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      },
                      child: Text("tap to log in"),
                    ),
                  ),
          ),
          Center(
            child: Container(
              child: Column(
                children: [
                  Column(
                      children: warnings.map((warning) {
                    return Text(
                        "-> ${warning["amount"]} grams of ${warning["ingredient"]} left",
                        style:
                            TextStyle(fontSize: 17.0, color: Colors.redAccent));
                  }).toList()),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Notes()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0), // Add padding here
                      child: Text(
                        "NOTES 🌏",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Analyser()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0), 
                      child: Text(
                        "RECIPE ANALYSER",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddItem()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0), // Add padding here
                      child: Text(
                        "ADD A NEW ITEM 🌏",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FilterStorage()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0), // Add padding here
                      child: Text(
                        "FILTER STORAGE 🌏",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Warnings()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0), // Add padding here
                      child: Text(
                        "ADD COSTUM WARNINGS-USE BY",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Weekly()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0), // Add padding here
                      child: Text(
                        "WEEKLY PLANNER",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Analyser()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0), // Add padding here
                      child: Text(
                        "QUICK SHOPPING LISTS",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Analyser()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0), // Add padding here
                      child: Text(
                        "30 DAY PLANNER",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      logout();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => super.widget),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0), // Add padding here
                      child: Text(
                        "LOGUS",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
