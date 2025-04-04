import 'dart:async';
import 'dart:convert';
// For rootBundle
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<List<dynamic>> fetchStorage() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  try {
    final response = await http.get(
      Uri.parse('http://192.168.1.8:5000/storage'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      await prefs.setBool('isSyncedItems', true);
      await prefs.setString('items', jsonEncode(data['items']));
      return data['storage'];
    }  else {
      print('Failed to load storage data: ${response.statusCode}');
      return [];
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

Future<void> resetStorageLocal() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // Remove the 'storage' key to reset the storage to null
  await prefs.remove('storage');
}

Future<List<dynamic>> getStorageLocal() async {

  final SharedPreferences prefs = await SharedPreferences.getInstance();
   //await prefs.remove('storage');
  String? items = prefs.getString('storage');
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
    print('Storage is null or not found');
    // If the storage is null, return an empty list
    return [];
  }
}





Future<void> delete(int itemID) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.delete(
      Uri.parse(
          'http://192.168.1.8:5000/storage/delete-storage-item-mobile/'),
      headers: {
        'Authorization': 'Bearer $token',
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
      Uri.parse('http://192.168.1.8:5000/storage/update-storage-mobile'),
      headers: {
        'Authorization': 'Bearer $token',
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

Future<void> addANewItem(
    String amount, String ingredient, String category) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.8:5000/storage/add-storage-item-mobile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(
          {'amount': amount, 'ingredient': ingredient, "category": category}),
    );
    if (response.statusCode == 404) {
      await prefs.setBool('isSyncedItems', false);
    } else if (response.statusCode != 200) {
      print("ERROR adding new item to storage");
    }
  } catch (e) {
    print('Error fetching storage data: $e');
  }
}

Future<void> updateCategory(String category, String id) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  try {
    final response = await http.put(
      Uri.parse('http://192.168.1.8:5000/storage/update-storage-mobile2'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'id': id,
        'category': category,
      }),
    );
    if (response.statusCode == 404) {
      await prefs.setBool('isSyncedItems', false);
    } else if (response.statusCode != 200) {
      print("ERROR adding new item to storage");
    }
  } catch (e) {
    print('Error fetching storage data: $e');
  }
}
