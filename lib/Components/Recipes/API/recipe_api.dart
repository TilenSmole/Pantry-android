import 'dart:async';
import 'dart:convert';
// For rootBundle
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../ShoppingList/API/shopping_cart_api.dart' as shoppingCartAPI;

Future<int?> addToSList(List ingredients, List amounts, String token) async { 
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.8:5000/shopping-list/add-to-shopping-list'),
      headers: {
        'Authorization': 'Bearer $token',
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
  return null;
}

Future<int?> addToSListLocal(List ingredients, List amounts, String token) async { 
   final SharedPreferences prefs = await SharedPreferences.getInstance();
   
    List<dynamic> shoppingCart = await shoppingCartAPI.getStorageLocal();


    for(int i =0; i < ingredients.length; i++){
      String? idItemStr = prefs.getString('idItem');
      int idItem = idItemStr != null ? int.parse(idItemStr) : 0;
      final Map<String, dynamic> item = {
            'id': idItem - 1,
            'amount': amounts[i],
            'ingredient':ingredients[i],
            'checked': false,
            'userId': 1,
          };
    await prefs.setString('idItem', (idItem - 1).toString());

    print(item);
    shoppingCart.add(item);


    }
  print(shoppingCart);
    shoppingCartAPI.updateStorageLocal(shoppingCart);
    return null;


}




Future<int?> cook(List ingredients, List amounts, String token) async {
  try {
    final response = await http.put(
      Uri.parse('http://192.168.1.8:5000/storage/cook'),
      headers: {
        'Authorization': 'Bearer $token',
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
  return null;
}

Future<List<dynamic>?> addNote(String note, int recipeID, String token) async {
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.8:5000/notes/add-note'),
      headers: {
        'Authorization': 'Bearer $token',
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
  return null;
}

Future<List<dynamic>?> deleteNote(
    int noteId, int recipeID, String token) async {
  try {
    final response = await http.delete(
      Uri.parse('http://192.168.1.8:5000/notes/delete-note'),
      headers: {
        'Authorization': 'Bearer $token',
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
  return null;
}

Future<List<dynamic>?> editNote(
    String newNote, int recipeID, int noteId, String token) async {
  try {
    final response = await http.put(
      Uri.parse('http://192.168.1.8:5000/notes/edit-note'),
      headers: {
        'Authorization': 'Bearer $token',
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
  return null;
}

Future<List<dynamic>?> getNotes(int recipeID, String? token) async {
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.8:5000/notes'),
      headers: {
        'Authorization': 'Bearer $token',
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
      print('Failed to upload to a shopping list from recipe');
    }
  } catch (e) {
    print('Error fetching recipes: $e');
  }
  return null;
}

Future<void> freezeItem(String amount, String ingredient,
    String category, String? token) async {
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
  int prepTime,
  int cookTime,
  String token,
) async {
  try {
    final response = await http.put(
      Uri.parse('http://192.168.1.8:5000/recipes/edit-recipe-mobile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'amount': amounts,
        'ingredient': ingredients,
        'recipeId': recipeId,
        'title': title,
        'instructions': instructions,
        'imageUrl': imageUrl,
        'prep_time': prepTime,
        'cook_time': cookTime,
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

Future<int> editCookTime(
  int recipeId,
  int cookTime,
  String token,
) async {
  try {
    final response = await http.put(
      Uri.parse('http://192.168.1.8:5000/recipes/edit-cook_time'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'recipeId': recipeId,
        'cook_time': cookTime,
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

Future<int> editPrepTime(
  int recipeId,
  int prepTime,
  String token,
) async {
  try {
    final response = await http.put(
      Uri.parse('http://192.168.1.8:5000/recipes/edit-prep_time'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'recipeId': recipeId,
        'prep_time': prepTime,
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
      Uri.parse('http://192.168.1.8:5000/recipes/edit-instructions'),
      headers: {
        'Authorization': 'Bearer $token',
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
      Uri.parse('http://192.168.1.8:5000/recipes/edit-ingredients'),
      headers: {
        'Authorization': 'Bearer $token',
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
