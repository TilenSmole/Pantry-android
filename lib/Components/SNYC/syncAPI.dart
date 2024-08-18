import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';

import 'dart:io'; // For SocketException
import 'dart:async'; // For TimeoutException
import 'package:http/http.dart' as http;

Future<void> uploadItems() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  final String? items = prefs.getString('items');
  if (items != null) {
    final List<dynamic> itemsList = jsonDecode(items);
    await http.put(
      Uri.parse(
          'http://192.168.1.179:5000/shopping-list/set-users-shopping-list-online'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'items': itemsList}),
    );
  }
}



Future<void> uploadStorage() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  final String? items = prefs.getString('storage');
  if (items != null) {
    final List<dynamic> storageList = jsonDecode(items);
        // Attempt to sync items with the server
        await http.post(
          Uri.parse(
              'http://192.168.1.179:5000/storage/set-storage'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'storage': storageList}),
        );
  }
}


Future<List<dynamic>> fetchRecipes() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      final response = await http.get(Uri.parse('http://192.168.1.179:5000/recipes'));
      if (response.statusCode == 200) {
              final Map<String, dynamic> data = jsonDecode(response.body);

         await prefs.setString('recipes', jsonEncode(data['Recipies']));
        return data['Recipies'];
      } else if (response.statusCode == 404) {
        final String? recipes = prefs.getString('recipes');
        if (recipes != null) {
          final List<dynamic> itemsList = jsonDecode(recipes);
          await prefs.setBool('isSyncedRecipes', false);
          return itemsList;
        }
        return [];
      } else {
        // If the server returns an error, throw an exception
        print('Failed to load recipes');
      }
    } catch (e) {
      print('Error fetching recipes: $e');
    }
    return [];
  }



