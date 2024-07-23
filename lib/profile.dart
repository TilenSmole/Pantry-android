import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import './Components/load_token.dart' as load_token;
import 'login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

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
    if (token != null) {
      await fetchRecipes(); // Fetch data only if token is available
    }
  }

  Future<void> fetchRecipes() async {
    print("Fetching recipes..."); // Debug print statement

    try {
      print({token});
      final response = await http.get(
        Uri.parse('http://192.168.1.179:5000/account/get-data-mobile'),
        headers: {
          'Authorization': 'Bearer ${token}',
          'Content-Type': 'application/json'
        },
      );
      print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        print('Raw JSON response: ${response.body}');
        setState(() {
          _user = jsonDecode(response.body) as Map<String, dynamic>; ;
          ;
        });
        // Print the data to the console

        print('User data saved successfully');
      } else {
        // If the server returns an error, throw an exception
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      print('Error fetching recipes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: Center(
        child: token != null
            ? Text(
          'WELCOME: ${_user["id"] == null ? "loading" : _user["username"].toString()} !',
          style: TextStyle(fontSize: 24),
        )
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
    );
  }
}
