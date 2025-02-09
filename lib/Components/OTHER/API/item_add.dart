import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<int?> addItem({
  required String name,
  required double calories,
  required double protein,
  required double fat,
  required double carbohydrates,
  required double fiber,
  required double sugar,
  required bool isVegan,
  required bool isVegetarian,
}) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('http://192.168.1.179:5000/foods/add-food-m'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'name': name,
        'calories': calories,
        'protein': protein,
        'fat': fat,
        'carbohydrates': carbohydrates,
        'fiber': fiber,
        'sugar': sugar,
        'isVegan': isVegan,
        'isVegetarian': isVegetarian,
      }),
    );

    if (response.statusCode == 200) {
      return 0;
    } else {
      print('Failed to add item. Status Code: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('Error adding item: $e');
  }
  return null;
}

Future<Map<int, String>> getItems() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.179:5000/foods/get-food-m'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> foods = data["food"];

      final Map<int, String> foodMap = {};
      for (var food in foods) {
        foodMap[food['id']] = food['name'];
      }

      return foodMap;
    } else {
      print('Failed to upload to a shopping list from recipe');
    }
  } catch (e) {
    print('Error fetching recipes: $e');
  }
  return {};
}



Future<List<dynamic>> getDisallowdItems() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.179:5000/foods/get-disallowd-food-m'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      return data["disallowedFood"];
    } else {
      print('Failed to upload to a shopping list from recipe');
    }
  } catch (e) {
    print('Error fetching recipes: $e');
  }
  return [];
}
