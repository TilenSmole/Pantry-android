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
import '../../Storage/API/StorageAPI.dart' as storageAPI;
import '../../../Classes/ListItem.dart';



Future<List<ListItem>> getItems() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  print("Fetching Shopping List");

  try {
    final response = await http.get(
      Uri.parse(
          'http://192.168.1.179:5000/shopping-list/get-users-shopping-list-mobile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  	  print(response);
    
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      List<dynamic> jsonData = responseData['items'];
      return jsonData.map((item) => ListItem.fromJson(item)).toList();
    } else {
      print('Failed to load storage data: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Error fetching Shopping List data: $e');
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
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'id': itemID,
      }),
    );
    if (response.statusCode == 404) {
      await prefs.setBool('isSyncedItems', false);
    } else if (response.statusCode != 200) {
      print("ERROR marking as bought in shopping list");
    }
  } catch (e) {
    print('Error fetching storage data: $e');
  }
}

Future<void> addStorageLocal(Map<String, dynamic> item) async {
  print(item);
   
  List<dynamic> storage = await storageAPI.getStorageLocal() ?? [];
  storage.add(item);
    print(storage);

  await storageAPI.updateStorageLocal(storage) ;



}

Future<void> updateStorageLocal(List shoppingCart) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  print(shoppingCart);
  await prefs.setString('items', jsonEncode(shoppingCart));
     String? items = prefs.getString('items');


  print("new item $items");

}


Future<List<dynamic>> getStorageLocal() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
//  await prefs.remove('items');
   String? items = prefs.getString('items');
     print("items");
     print(items);

  if (items != null) {
    try {
      final decodedData = jsonDecode(items);
      print(decodedData);
      if (decodedData is List<dynamic>) {
        return decodedData;
      } else {
        print('Unexpected data type: ${decodedData.runtimeType}');
        return [];
      }
    } catch (e) {
      // Handle JSON decoding errors
      print('Error decoding JSON: $e');
      return [];
    }
  } else {
    // Handle the case where items is null
    return [];
  }

}




Future<void> delete(int itemID) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  try {
    final response = await http.delete(
      Uri.parse('http://192.168.1.179:5000/shopping-list/delete-item-mobile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'id': itemID,
      }),
    );
    if (response.statusCode == 404) {
      await prefs.setBool('isSyncedItems', false);
    } else if (response.statusCode != 200) {
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
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'amount': amount,
        'ingredient': ingredient,
      }),
    );
    if (response.statusCode == 404) {
      await prefs.setBool('isSyncedItems', false);
    } else if (response.statusCode != 200) {
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
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'id': id,
        'amount': amount,
        'ingredient': ingredient,
      }),
    );
    if (response.statusCode == 404) {
      await prefs.setBool('isSyncedItems', false);
    } else if (response.statusCode != 200) {
      print("ERROR updating item in the shopping list");
    }
  } catch (e) {
    print('Error fetching storage data: $e');
  }
}
