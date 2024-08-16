import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:http/http.dart' as http;


 Future<List> fetchRecipes() async {
    print("Fetching recipes..."); // Debug print statement

    try {
      final response =
          await http.get(Uri.parse('http://192.168.1.179:5000/recipes'));
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (response.statusCode == 200) {

       
        return data['Recipies'];

      } else {
        // If the server returns an error, throw an exception
        print('Failed to load recipes');
      }
    } catch (e) {
      print('Error fetching recipes: $e');
    }
    return [];
  }