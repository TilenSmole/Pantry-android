import 'dart:convert';
import 'package:flutter/services.dart';
import '../load_ingredients.dart';

class caloriesCalculator {
  var total = 0;
  Map<String, List<String>> data = {};
  List<dynamic> ingredients = [];


  caloriesCalculator( this.ingredients) {
  loadFood().then((_) => calculate());
  }

  Future<void> loadFood() async {
    IngredientLoader loader = IngredientLoader();
    await Future.delayed(Duration(seconds: 1)); // Give it some time to load
    data = loader.allSuggestions;
  }



  void calculate() {
          print(data);
// { "id": 1, "name": "Apple", "calories": 52, "protein": 0.26, "fat": 0.17, "carbohydrates": 13.81, "fiber": 2.4, "sugar": 10.39, "allergens": [], "is_vegan": true, "is_vegetarian": true },

    for(var item in ingredients ){
      var ingredient = item["ingredient"].toString().toLowerCase();
      var amount = item["amount"].toString().toLowerCase();
      print(ingredient);
      print(data[ingredient]?[1]);
    }



  }

  num getCalories() {
    return total;
  }
}
