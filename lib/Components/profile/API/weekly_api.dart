import 'dart:async';
import 'dart:convert';
// For rootBundle
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


Future<bool> performActionOnceOnMonday() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  if (DateTime.now().weekday != DateTime.monday) {
    return false;
  }

  String? lastPerformedDate = prefs.getString('lastPerformedMonday');
  String todayDate = DateTime.now().toIso8601String().split('T')[0];

  if (lastPerformedDate != todayDate) {
        
    await prefs.setString('lastPerformedMonday', todayDate);

    return true;
  }

  return false;
}




Future<List<dynamic>> fetchCostumRecipes(token, number) async {

  var isMonday = await performActionOnceOnMonday();

  if (!isMonday) {
    return getStorageLocal();
  }

  print("Having to update the list!");
  List<dynamic> recipes =  await apiCall(token, number);
  resetWeeklyLocal();
  updateWeeklyLocal(recipes);
  return recipes;
}

Future<List<dynamic>> apiCall(token, number) async {
try {
    final response = await http.post(
      Uri.parse('http://192.168.1.8:5000/recipes/fetch-costum'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'number': number,
      }),
    );

   if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        return data['recipes'];
      } else if (response.statusCode == 404) {
        
        return [];
      } else {
        // If the server returns an error, throw an exception
        print('Failed to load recipes');
      }
  } catch (e) {
    print('Error fetching recipes: $e');
  }
return [
    {"id": 0, "note": "failed to load", "userId": 1},
  ];
}



Future<List<dynamic>> replace(token, position) async {



  List<dynamic> recipie =  await apiCall(token, 1);
  print(recipie);
  updateCertainWeeklyLocal(recipie, position);
  return getStorageLocal();

  
 
}

Future<void> updateCertainWeeklyLocal(List<dynamic> recipie, int position) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  
  String? weeklyJson = prefs.getString('weekly');
  
  if (weeklyJson != null) {
    List<dynamic> weekly = jsonDecode(weeklyJson);

    if (position >= 0 && position < weekly.length) {
      weekly[position] = recipie[0]; 
      
      await prefs.setString('weekly', jsonEncode(weekly));
    } else {
      print('Invalid position');
    }
  }
}



Future<void> updateWeeklyLocal(List weekly) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('weekly', jsonEncode(weekly));
}

Future<void> resetWeeklyLocal() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('weekly');
}



Future<List<dynamic>> getStorageLocal() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
   String? items = prefs.getString('weekly');
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

