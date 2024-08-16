import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:http/http.dart' as http;
import 'package:pantry_app/recipies.dart';
import '../load_token.dart' as load_token;
import '../../main.dart';
import '../Recipes/API/recipes.API.dart' as API;
import '../Storage/API/StorageAPI.dart' as StorageAPI;
import '../Recipes/recipie.dart';

class Analyser extends StatefulWidget {
  @override
  _analyserState createState() => _analyserState();
}

class _analyserState extends State<Analyser> {
  List _recipes = [];
  String? token;
  List _storage = [];

  Map<int, String> _analyse = {};

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final loadedToken = await load_token.loadToken();

    setState(() {
      token = loadedToken;
    });
    getRecipes().then((_) {
      getstorage().then((_) {
        getstorage();
        analyse();
      });
    });
  }

  getRecipes() async {
    var result = await await API.fetchRecipes();
    setState(() {
      _recipes = result;
    });
  }

  getstorage() async {
    var result = await await StorageAPI.fetchStorage(token!);
    setState(() {
      _storage = result;
    });
  }

  void analyse() async {
    double result = 100;
    double nItems = 0;
    double part = 0;
        var index1 = 0;
    var included = true;
    for (var recipe in _recipes) {
      nItems = (recipe["ingredients"].length).toDouble();
      part = (100 / nItems);
              index1 = 0;

      for (var ingredient in recipe["ingredients"]) {
        for (var storageItem in _storage) {
          if (storageItem["ingredient"].toLowerCase() ==  (ingredient.toLowerCase())) {

              /*  print(recipe["amounts"][index1]);
                print(storageItem["amount"]);
  print(storageItem["ingredient"].toLowerCase());
  print(ingredient.toLowerCase());
  print("--------------");*/

            RegExp numberRegExp = RegExp(r'\d+(\.\d+)?');
            Match? number1Match =       numberRegExp.firstMatch(storageItem["amount"]);
            Match? number2Match =          numberRegExp.firstMatch(recipe["amounts"][index1]);

            double? number1 = number1Match != null ? double.tryParse(number1Match.group(0)!)      : 0;
            double? number2 = number2Match != null    ? double.tryParse(number2Match.group(0)!)       : 0;

            // Match the units (letters only)
            RegExp unitRegExp = RegExp(r'[a-zA-Z]+');
            Match? unit1Match = unitRegExp.firstMatch(storageItem["amount"]);
            Match? unit2Match =     unitRegExp.firstMatch(recipe["amounts"][index1]);

            // Extract the matched units as strings
            String? unit1 = unit1Match?.group(0);
            String? unit2 = unit2Match?.group(0);
           if (number1 != null && unit1 == "kg" && unit2 == "g" ||
                unit2 == "grams") {
              number1 = number1! * 1000;
              unit1 = "g";
            } else if (number2 != null && unit2 == "kg" && unit1 == "g" ||
                unit1 == "grams") {
              number2 = number2! * 1000;
              unit2 = "g";
            }
            if (number1 != null && unit2 != null && unit1 != null && unit1!.toLowerCase() == "l" && unit2!.toLowerCase() == "ml" ) {
              number1 = number1! * 1000;
              unit1 = "ml";
            } else if (number2 != null && unit2 != null && unit1 != null && unit2!.toLowerCase() == "l" && unit1!.toLowerCase() == "ml") {
              number1 = number1! * 1000;
              unit1 = "ml";
            }
    /*      print(storageItem["ingredient"].toLowerCase() );
            print(unit1);
              print(unit2);
   print(number1);
              print(number2);*/

            if (number1! >= number2! && unit1 == unit2) {
              included = false;
          break;
            }
                
          }
       
        }
        index1++;
        if (included) {
          result -= part;
          if (result < 0.1) {
            result = 0;
          }
        }
        included = true;
       
      }
      //    print(recipe["name"] + " " + result.toString());
      _analyse[recipe["id"]] = result.toStringAsFixed(2);
      result = 100;
    }
   // print(_analyse);
    setState(() {
      _analyse = Map.fromEntries(
        sortMapByValuesDescending(_analyse),
      );
    });
  }

  List<MapEntry<int, String>> sortMapByValuesDescending(
      Map<int, String> map) {
    List<MapEntry<int, String>> sortedEntries = map.entries.toList()
      ..sort((a, b) {
        double valueA = double.tryParse(a.value) ?? 0;
        double valueB = double.tryParse(b.value) ?? 0;
        return valueB.compareTo(valueA);
      });

    return sortedEntries;
  }

 findRecipe(var id)  {
    for(var recipe in _recipes){
      if(id == recipe["id"]){
        return recipe;
      }
    }
  }
 findRecipeName(var id)  {
    for(var recipe in _recipes){
      if(id == recipe["id"]){
        return recipe["name"];
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ANALYSER'),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0), // Add padding if needed
        child: ListView(
          
          children: _analyse.entries.map((entry) {
            return GestureDetector (
              onTap: () {
                 Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Recepie(recipe: findRecipe(entry.key) )));
              },
              child: ListTile(
                title: Text(' ${findRecipeName(entry.key)}'),
                subtitle: Text(' ${entry.value}%'),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
