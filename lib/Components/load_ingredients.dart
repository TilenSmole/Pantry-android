import 'dart:convert';
import 'package:flutter/services.dart';

class IngredientLoader {
  List<String> _allSuggestions = [];

  IngredientLoader() {
    _init();
  }

  void _init() {
    setFood('Vegetables.json', 'vegetables');
    setFood('Fruits.json', 'fruits');
    setFood('Condiments.json', 'condiments');
    setFood('Dairy.json', 'dairy');
    setFood('Grains.json', 'grains');
    setFood('Legumes.json', 'legumes');
    setFood('Meat.json', 'meat');
    setFood('Nuts and Seeds.json', 'nuts');
    setFood('Seafood.json', 'seafood');
    setFood('Spices and Herbs.json', 'spicesHerbs');
  }

  Future<void> setFood(String fileName, String key) async {
    try {
      // Load the JSON file from assets
      final String response = await rootBundle.loadString('FOODS/$fileName');

      // Decode the JSON response
      final Map<String, dynamic> data = json.decode(response);

      // Extract the list based on the provided key
      List<dynamic> items = data[key];

      // Extract item names and related info, ensure the value is a List<String>
      List<String> names = items.map((item) {
        return item["name"].toString(); // Change "name" if the key is different
      }).toList();

      // Add the extracted data to the suggestions map
      _allSuggestions.addAll(names);

    } catch (e) {
      print('Error loading or parsing JSON: $e');
    }
  }

  List<String> get allSuggestions => _allSuggestions;
}
