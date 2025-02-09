import 'dart:async';
import 'dart:convert';
// For rootBundle
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


 Future<List<dynamic>> fetchRecipes() async {
    print('Trying to fetch receipes');

    try {
      final response = await http.get(Uri.parse('http://192.168.1.179:5000/recipes'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        print( data['Recipies']);
        return data['Recipies'];
      } else if (response.statusCode == 404) {
        
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

Future<List<dynamic>> getStorageLocal() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
   String? items = prefs.getString('recipes');
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

