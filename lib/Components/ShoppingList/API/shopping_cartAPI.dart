import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<List<dynamic>> getItems() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  final bool isSyncedItems = prefs.getBool('isSyncedItems') ?? false;

  try {
    if (!isSyncedItems) {
      final String? items = prefs.getString('items');
      if (items != null) {
        final List<dynamic> itemsList = jsonDecode(items);
        // Attempt to sync items with the server
        await http.put(
          Uri.parse(
              'http://192.168.1.179:5000/shopping-list/set-users-shopping-list-online'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'items': itemsList}),
        );
        await prefs.setBool('isSyncedItems', true);
        return itemsList;
      } else {
        return [];
      }
    } else {
      final response = await http.get(
        Uri.parse(
            'http://192.168.1.179:5000/shopping-list/get-users-shopping-list-mobile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        await prefs.setString('items', jsonEncode(data['items']));
        return data['items'];
      } else if (response.statusCode == 404) {
        print("Items not found on the server.");
        final String? items = prefs.getString('items');
        if (items != null) {
          final List<dynamic> itemsList = jsonDecode(items);
          await prefs.setBool('isSyncedItems', false);
          return itemsList;
        }
        return [];
      } else {
        print('Failed to load storage data: ${response.statusCode}');
        return [];
      }
    }
  } catch (e) {
    print('Error fetching storage data: $e');
    return [];
  }
}

Future<void> bought(int itemID) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  try {
    final response = await http.put(
      Uri.parse('http://192.168.1.179:5000/storage/add-item-from-sList-mobile'),
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'id': itemID,
      }),
    );
    if (response.statusCode != 200) {
      print("ERROR marking as bought in shopping list");
    } 
  } catch (e) {
    print('Error fetching storage data: $e');
  }
}

Future<void> updateStorageLocal(List shopping_cart) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isSyncedItems', false);

  await prefs.setString('items', jsonEncode(shopping_cart));
}

Future<void> delete(int itemID) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  try {
    final response = await http.delete(
      Uri.parse('http://192.168.1.179:5000/shopping-list/delete-item-mobile'),
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'id': itemID,
      }),
    );
    if (response.statusCode != 200) {
      print("ERROR deleting from shopping list");
    } 
  } catch (e) {
    print('Error fetching storage data: $e');
  }
}

Future<void> uploadItem(String amount, String ingredient) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  try {
    final response = await http.post(
        Uri.parse(
            'http://192.168.1.179:5000/shopping-list/add-a-shopping-list-mobile'),
        headers: {
          'Authorization': 'Bearer ${token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'amount':amount,
          'ingredient': ingredient,
        }),
      );
    if (response.statusCode != 200) {
      print("ERROR uploading to the shopping list");
    } 
  } catch (e) {
    print('Error fetching storage data: $e');
  }
}



Future<void> updateItem(String amount, String ingredient, int id) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  try {
    final response = await http.put(
        Uri.parse(
            'http://192.168.1.179:5000/shopping-list/update-a-shopping-list-mobile'),
        headers: {
          'Authorization': 'Bearer ${token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'id': id,
          'amount':amount,
          'ingredient': ingredient,
        }),
      );
    if (response.statusCode != 200) {
      print("ERROR updating item in the shopping list");
    } 
  } catch (e) {
    print('Error fetching storage data: $e');
  }
}


