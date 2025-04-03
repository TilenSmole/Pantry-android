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
      Uri.parse('http://192.168.1.8:5000/foods/add-food-m'),
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

Future<Map<int, dynamic>> getItems() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.8:5000/foods/get-food-m'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> foods = data["food"];

      final Map<int, dynamic> foodMap = {};
      for (var food in foods) {
        foodMap[food['id']] = food;
      }
      print(foodMap);
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
      Uri.parse('http://192.168.1.8:5000/foods/get-disallowd-food-m'),
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


Future<bool> setDisallowdItems(id,set ) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.8:5000/foods/set-disallowd-food-m'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'disallowedId': id,
        'set': set,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to upload disallowed item');
    }
  } catch (e) {
    print('Error fetching recipes: $e');
  }
  return false;
}




Future<bool> setStorageOnly() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.8:5000/account/set-storage-only-m'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to update saving only storage');
    }
  } catch (e) {
    print('Error fetching recipes: $e');
  }
  return false;
}
Future<bool> getStorageOnly() async {



  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.8:5000/account/get-storage-only-m'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
         final Map<String, dynamic> data = jsonDecode(response.body);

      return data["existingValue"];
    } else {
      print('Failed to update saving only storage');
    }
  } catch (e) {
    print('Error fetching recipes: $e');
  }
  return false;
}



Future<List<dynamic>> getCategories() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.8:5000/foods/get-categories-m'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> categories = jsonDecode(response.body);
        print(categories);

      return categories;
    } else {
      print('Failed to getCategories');
    }
  } catch (e) {
    print('Error getCategories: $e');
  }
  return [];
}

Future<int> changeDefaultCategory(foodId,newCategory) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.8:5000/foods/change-category-m'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'foodId': foodId,
        'newCategory': newCategory,
      }),
    );
    return response.statusCode;
   
  } catch (e) {
    print('Error getCategories: $e');
  }
  return 0;
}


Future<int> setWarning(foodId, warning) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.8:5000/foods/set-warning'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'foodId': foodId,
        'warning': warning,
      }),
    );
    return response.statusCode;
   
  } catch (e) {
    print('Error getCategories: $e');
  }
  return 0;
}
