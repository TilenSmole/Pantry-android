import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<List<dynamic>> fetchStorage() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  final bool isSyncedStorage = prefs.getBool('isSyncedStorage') ?? false;
  try {
    if (!isSyncedStorage) {
      final String? storage = prefs.getString('storage');
      if (storage != null) {
        final List<dynamic> storageList = jsonDecode(storage);
        // Attempt to sync items with the server
        await http.put(
          Uri.parse(
              'http://192.168.1.179:5000/shopping-list/set-users-shopping-list-online'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'storage': storageList}),
        );
        await prefs.setBool('isSyncedStorage', true);
        return storageList;
      } else {
        return [];
      }
    } else {
      final response = await http.get(
        Uri.parse('http://192.168.1.179:5000/storage'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        await prefs.setString('items', jsonEncode(data['items']));
        return data['storage'];
      } else if (response.statusCode == 404) {
        print("Items not found on the server.");
        final String? storage = prefs.getString('items');
        if (storage != null) {
          final List<dynamic> itemsList = jsonDecode(storage);
          await prefs.setBool('isSyncedStorage', false);
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

Future<void> updateStorageLocal(List storage) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.setString('storage', jsonEncode(storage));
}

Future<void> delete(int itemID) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.delete(
      Uri.parse(
          'http://192.168.1.179:5000/storage/delete-storage-item-mobile/'),
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'id': itemID,
      }),
    );

    if (response.statusCode != 200) {
      print('Failed to delete from storage');
    } else if (response.statusCode == 404) {
      await prefs.setBool('isSyncedStorage', false);
    }
  } catch (e) {
    print('Error fetching recipes: $e');
  }
}

Future<void> updateItem(int itemID, String amount, ingredient) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.put(
      Uri.parse('http://192.168.1.179:5000/storage/update-storage-mobile'),
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'amount': amount,
        'ingredient': ingredient,
        'id': itemID,
      }),
    );

    if (response.statusCode != 200) {
      print('Failed to update item in storage');
    } else if (response.statusCode == 404) {
      await prefs.setBool('isSyncedStorage', false);
    }
  } catch (e) {
    print('Error fetching recipes: $e');
  }
}


Future<void> addANewItem(String amount, String ingredient, List categories) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  try {
        final response = await http.post(
        Uri.parse('http://192.168.1.179:5000/storage/add-storage-item-mobile'),
        headers: {
          'Authorization': 'Bearer ${token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'amount': amount,
          'ingredient': ingredient,
          "category": categories
        }),
      );
    if (response.statusCode == 404) {
      await prefs.setBool('isSyncedItems', false);
    }
    else if (response.statusCode != 200) {
      print("ERROR adding new item to storage");
    }
  } catch (e) {
    print('Error fetching storage data: $e');
  }
}
