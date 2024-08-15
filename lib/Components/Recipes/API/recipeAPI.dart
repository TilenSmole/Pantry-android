import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:http/http.dart' as http;

Future<int?> addToSList(List ingredients, List amounts, String token) async {
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.179:5000/storage/add-to-shopping-list'),
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'amounts': amounts,
        'ingredients': ingredients,
      }),
    );

    //print(response.statusCode);
    //print(jsonDecode(response.body));

    if (response.statusCode == 200) {
      // final Map<String, dynamic> responseJson = jsonDecode(response.body);
      return 0;
      // Extract the token from the JSON object
      // final String? token = responseJson['token'];
    } else {
      print('Failed to ');
    }
  } catch (e) {
    print('Error fetching recipes: $e');
  }
}

Future<int?> cook(List ingredients, List amounts, String token) async {
  try {
    final response = await http.put(
      Uri.parse('http://192.168.1.179:5000/storage/cook'),
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'amounts': amounts,
        'ingredients': ingredients,
      }),
    );

    print(response.statusCode);
    print(jsonDecode(response.body));

    if (response.statusCode == 200) {
      // final Map<String, dynamic> responseJson = jsonDecode(response.body);

      // Extract the token from the JSON object
      // final String? token = responseJson['token'];
      return 1;
    } else {
      throw Exception('Failed to load recipes');
    }
  } catch (e) {
    print('Error fetching recipes: $e');
  }
}

Future<List<dynamic>?> addNote(String note, int recipeID, String token) async {
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.179:5000/notes/add-note'),
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'note': note,
        'recipeID': recipeID,
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
}

Future<List<dynamic>?> deleteNote(
    int noteId, int recipeID, String token) async {
  try {
    final response = await http.delete(
      Uri.parse('http://192.168.1.179:5000/notes/delete-note'),
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'noteId': noteId,
        'recipeID': recipeID,
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
}

Future<List<dynamic>?> editNote(
    String newNote, int recipeID, int noteId, String token) async {
  try {
    final response = await http.put(
      Uri.parse('http://192.168.1.179:5000/notes/edit-note'),
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(
          {'newNote': newNote, 'recipeID': recipeID, 'noteId': noteId}),
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
}

Future<List<dynamic>?> getNotes(int recipeID, String? token) async {
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.179:5000/notes/'),
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'recipeID': recipeID,
      }),
    );

    // print(response.statusCode);
    // print(jsonDecode(response.body));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      print(data["notes"]);
      print(data);

      return data["notes"];
    } else {
      print('Failed to upload to a shopping list from a recipe');
    }
  } catch (e) {
    print('Error fetching recipes: $e');
  }
}

Future<void> freezeItem(String amount, String ingredient,
    List<dynamic>? categories, String? token) async {
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.179:5000/storage/add-storage-item-mobile'),
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(
          {'amount': amount, 'ingredient': ingredient, "category": categories}),
    );

    if (response.statusCode == 200) {
      print("Update successful");
    } else {
      throw Exception('Failed to update item');
    }
  } catch (e) {
    print('Error updating item: $e');
  }
}

Future<int> editRecipe(
  String title,
  int recipeId,
  List<dynamic> ingredients,
  String instructions,
  List<dynamic> amounts,
  String imageUrl,
  int prep_time,
  int cook_time,
  String token,
) async {
  Map<String, dynamic> recipe = {
    'name': 'Unknown Recipe',
    'ingredients': [], // Default to an empty list
    'amounts': [], // Default to an empty list
    'instructions': 'No instructions available',
    'cook_time': '0', // Default cooking time
    'prep_time': '0', // Default preparation time
    'imageUrl': '', // Default to an empty string or placeholder image URL
  };
  try {
    final response = await http.put(
      Uri.parse('http://192.168.1.179:5000/recipes/edit-recipe-mobile'),
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'amount': amounts,
        'ingredient': ingredients,
        'recipeId': recipeId,
        'title': title,
        'instructions': instructions,
        'imageUrl': imageUrl,
        'prep_time': prep_time,
        'cook_time': cook_time,
      }),
    );
    if (response.statusCode == 200) {
      return 0;
    } else {
      print('Failed to update item');
    }
  } catch (e) {
    print('Error updating item: $e');
  }
  return -1;
}

Future<int> edit_cook_time(
  int recipeId,
  int cook_time,
  String token,
) async {
  try {
    final response = await http.put(
      Uri.parse('http://192.168.1.179:5000/recipes/edit-cook_time'),
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'recipeId': recipeId,
        'cook_time': cook_time,
      }),
    );
    if (response.statusCode == 200) {
      return 0;
    } else {
      print('Failed to update item');
    }
  } catch (e) {
    print('Error updating item: $e');
  }
  return -1;
}

Future<int> edit_prep_time(
  int recipeId,
  int prep_time,
  String token,
) async {
  try {
    final response = await http.put(
      Uri.parse('http://192.168.1.179:5000/recipes/edit-prep_time'),
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'recipeId': recipeId,
        'prep_time': prep_time,
      }),
    );
    if (response.statusCode == 200) {
      return 0;
    } else {
      print('Failed to update item');
    }
  } catch (e) {
    print('Error updating item: $e');
  }
  return -1;
}

Future<int> editInstructions(
  int recipeId,
  String instructions,
  String token,
) async {
  try {
    final response = await http.put(
      Uri.parse('http://192.168.1.179:5000/recipes/edit-instructions'),
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'recipeId': recipeId,
        'instructions': instructions,
      }),
    );
    if (response.statusCode == 200) {
      return 0;
    } else {
      print('Failed to update item');
    }
  } catch (e) {
    print('Error updating item: $e');
  }
  return -1;
}

Future<int> editIngredients(
  int recipeId,
  List<dynamic> ingredients,
  List<dynamic> amounts,
  String token,
) async {
  try {
    final response = await http.put(
      Uri.parse('http://192.168.1.179:5000/recipes/edit-ingredients'),
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'recipeId': recipeId,
        'ingredients': ingredients,
        'amounts': amounts,
      }),
    );
    if (response.statusCode == 200) {
      return 0;
    } else {
      print('Failed to update item');
    }
  } catch (e) {
    print('Error updating item: $e');
  }
  return -1;
}
