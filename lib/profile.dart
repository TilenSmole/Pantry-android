import 'package:flutter/material.dart';
import './Components/load_token.dart' as load_token;
import 'login.dart';
import './Components/logout.dart';
import 'dart:async';
import 'Components/PROFILE/notes.dart';
import 'Components/OTHER/item_add.dart';
import 'Components/OTHER/filter_storage.dart';

import 'Components/PROFILE/analyser.dart';
import './Components/SNYC/syncAPI.dart' as API;

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? token;
  Map<String, dynamic> _user = {};
  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final loadedToken = await load_token.loadToken();
    setState(() {
      token = loadedToken;
    });
    if (token != null) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: Column(
        children: [
          Center(
            child: token != null
                ? Column(children: [
                    Text(
                        'WELCOME: ${_user["id"] == null ? "loading" : _user["username"].toString()} !',
                        style: TextStyle(fontSize: 24)),
                  ])
                : Padding(
                    padding: const EdgeInsets.all(8.0),
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
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Notes()),
                      );
                    },
                    child: Text(
                      "NOTES",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Analyser()),
                      );
                    },
                    child: Text(
                      "RECIPE ANALYSER",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddItem()),
                      );
                    },
                    child: Text(
                      "ADD A NEW ITEM",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                   InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FilterStorage()),
                      );
                    },
                    child: Text(
                      "FILTER STORAGE",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      logout();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => super.widget));
                    },
                    child: Text("LOGOUT"),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
