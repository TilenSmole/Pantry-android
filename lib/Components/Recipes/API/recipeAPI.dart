 
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:http/http.dart' as http;


 
 Future<int?> addToSList(List ingredients,List amounts,String token ) async {
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


   Future<int?> cook(List ingredients,List amounts,String token ) async {
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


 Future<List<dynamic>?> addNote(String note, int recipeID,String token ) async {
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
      

        return  data["notes"];


      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      print('Error fetching recipes: $e');
    }
    
  }



  Future<List<dynamic>?> deleteNote(int noteId, int recipeID,String token ) async {
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
      

        return  data["notes"];
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      print('Error fetching recipes: $e');
    }
    
  }


  Future<List<dynamic>?> editNote(String newNote, int recipeID, int noteId,String token ) async {
    try {
      final response = await http.put(
        Uri.parse('http://192.168.1.179:5000/notes/edit-note'),
        headers: {
          'Authorization': 'Bearer ${token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'newNote': newNote,
          'recipeID': recipeID,
          'noteId' : noteId

        }),
      );
            


      if (response.statusCode == 200) {
         final Map<String, dynamic> data = jsonDecode(response.body);
      

        return  data["notes"];
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      print('Error fetching recipes: $e');
    }
    
  }


Future<List<dynamic>?> getNotes( int recipeID,String?  token ) async {
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

        return  data["notes"];
      

       
      } else {
        print('Failed to upload to a shopping list from a recipe');
      }
    } catch (e) {
      print('Error fetching recipes: $e');
    }
    
  }