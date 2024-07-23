import 'package:flutter/material.dart';


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Profile extends StatelessWidget {
  // Fetch recipes function
  Future<List<dynamic>> fetchRecipes() async {
  print("Fetching recipes..."); // Debug print statement

  final response = await http.get(Uri.parse('http://192.168.1.179:5000/recipes')); // Update URL if needed

  if (response.statusCode == 200) {
    // If the server returns a 200 OK response, parse the JSON
    return jsonDecode(response.body) as List<dynamic>; // Parse response as list
  } else {
    // If the server returns an error, throw an exception
    throw Exception('Failed to load recipes');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: Center(
        child: FutureBuilder<List<dynamic>>(
          future: fetchRecipes(), // Call fetchRecipes
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Show loading indicator
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}'); // Display error message
            } else if (snapshot.hasData) {
              // Display fetched data
              return Text(
                'Recipes: ${snapshot.data}',
                style: TextStyle(fontSize: 24),
              );
            } else {
              return Text('No data'); // Handle no data case
            }
          },
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
  home: Profile(),
));
