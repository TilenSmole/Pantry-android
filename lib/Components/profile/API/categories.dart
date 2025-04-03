import 'dart:async';
import 'dart:convert';
// For rootBundle
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> addCategory(String category, String token) async {
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.8:5000/storage/add-category'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'category': category,
      }),
    );

    
  } catch (e) {
    print('Error fetching recipes: $e');
  }
  return ;
}

Future<List<dynamic>?> deleteCategorye(int noteId, String token) async {
  try {
    final response = await http.delete(
      Uri.parse('http://192.168.1.8:5000/notes/delete-note'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'noteId': noteId,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      return data["notes"];
    } else {
      throw Exception('Failed to load recipes');
    }
  } catch (e) {
    print('Error fetching recipes: $e');
  }
  return null;
}

Future<void> editCategory(
    String category, int categoryID, String token) async {
  try {
    final response = await http.put(
      Uri.parse('http://192.168.1.8:5000/storage/update-category'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({'category': category, 'categoryID': categoryID}),
    );

    
  } catch (e) {
    print('Error fetching recipes: $e');
  }
  return ;
}

Future<List<dynamic>> getCategories(String? token) async {
  try {
    final response = await http.get(
      Uri.parse('http://192.168.1.8:5000/storage/get-categories'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
            final List<dynamic> categories = jsonDecode(response.body);
      print("categories" );
            print(categories );

      return categories;

    } else if (response.statusCode == 404) {
    } 
  } catch (e) {
    print('Error fetching categories: $e');
  }
  return [
    {"id": 0, "note": "failed to load", "userId": 1},
  ];
}

