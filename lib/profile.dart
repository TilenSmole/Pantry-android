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
import 'Components/PROFILE/analyser.dart';
import 'Components/OTHER/API/warnings.dart' as WARNINGS_API;
import 'Components/PROFILE/categories.dart';
import './Components/HELPERS/colors.dart';

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

  Future<void> _checkLoginStatus() async {
    
    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
  }


  Future<void> _loadData() async {
    final loadedToken = await load_token.loadToken();
    List<dynamic> warningsFetched = await WARNINGS_API.getWarnings();

    setState(() {
      token = loadedToken;
      warnings = warningsFetched;
    });

     _checkLoginStatus();


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0, left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: 
                   Column(
                      children: [
                        SizedBox(height: 20),
                        Text(
                          'WELCOME: ${token == null ? "loading" : _user["id"].toString()} !',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                 
            ),
            Expanded(
              child: ListView(
                children: [
                  // Map over warnings and create cards
                  ...warnings.map((warning) {
                    return Card(
                      color: Colors.red.shade100,
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "-> ${warning["amount"]} grams of ${warning["ingredient"]} left",
                          style: TextStyle(
                              fontSize: 17.0, color: Colors.redAccent),
                        ),
                      ),
                    );
                  }).toList(),

                  // Menu items
                  _buildMenuItem(context, "NOTES", Notes()),
                  _buildMenuItem(context, "RECIPE ANALYSER", Analyser()),
                  _buildMenuItem(context, "ADD A NEW ITEM", AddItem()),
                  _buildMenuItem(context, "FILTER STORAGE", FilterStorage()),
                  _buildMenuItem(context, "WEEKLY PLANNER", Weekly()),
                 // _buildMenuItem(context, "QUICK SHOPPING LISTS", Analyser()),
               //   _buildMenuItem(context, "30 DAY PLANNER", Analyser()),
                  _buildMenuItem(context, "CATEGORIES", Categories()),

                  // Log out button
                  InkWell(
                    onTap: () {
                      logout();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => super.widget),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      color: C.darkGrey,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Center(
                          child: Text(
                            "LOG OUT",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: C.red),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ) 
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, Widget page) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Card(
        elevation: 4,
        color: C.darkGrey,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
          ),
        ),
      ),
    );
  }
}
