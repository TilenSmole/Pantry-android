import 'package:flutter/material.dart';
import '../Recipes/API/recipes.API.dart' as API;
import '../Storage/API/StorageAPI.dart' as StorageAPI;
import '../Recipes/recipie.dart';
import '../HELPERS/colors.dart';

class Analyser extends StatefulWidget {
  @override
  AnalyserState createState() => AnalyserState();
}

class AnalyserState extends State<Analyser> {
  List _recipes = [];
  List _storage = [];
  Map<int, String> _analyse = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await getRecipes();
    await getStorage();
    analyse();
  }

  Future<void> getRecipes() async {
    var result = await API.fetchRecipes();
    setState(() => _recipes = result);
  }

  Future<void> getStorage() async {
    var result = await StorageAPI.fetchStorage();
    setState(() => _storage = result);
  }

  void analyse() {
    for (var recipe in _recipes) {
      double percentage = 100;
      double ingredientCount = recipe["ingredients"].length.toDouble();
      double portion = 100 / ingredientCount;
      
      for (var i = 0; i < recipe["ingredients"].length; i++) {
        var ingredient = recipe["ingredients"][i].toLowerCase();
        bool isAvailable = _storage.any((item) {
          return item["ingredient"].toLowerCase() == ingredient &&
                 _compareAmounts(item["amount"], recipe["amounts"][i]);
        });

        if (!isAvailable) {
          percentage -= portion;
          if (percentage < 0.1) percentage = 0;
        }
      }
      
      _analyse[recipe["id"]] = percentage.toStringAsFixed(2);
    }
    
    setState(() {
      _analyse = Map.fromEntries(
        _analyse.entries.toList()
          ..sort((a, b) => double.parse(b.value).compareTo(double.parse(a.value))),
      );
    });
  }

  bool _compareAmounts(String storageAmount, String recipeAmount) {
    RegExp numberRegExp = RegExp(r'\d+(\.\d+)?');
    RegExp unitRegExp = RegExp(r'[a-zA-Z]+');

    double storageValue = double.tryParse(numberRegExp.firstMatch(storageAmount)?.group(0) ?? '0') ?? 0;
    double recipeValue = double.tryParse(numberRegExp.firstMatch(recipeAmount)?.group(0) ?? '0') ?? 0;
    
    String? storageUnit = unitRegExp.firstMatch(storageAmount)?.group(0);
    String? recipeUnit = unitRegExp.firstMatch(recipeAmount)?.group(0);
    
    if (storageUnit == "kg" && (recipeUnit == "g" || recipeUnit == "grams")) {
      storageValue *= 1000;
      storageUnit = "g";
    } else if (recipeUnit == "kg" && (storageUnit == "g" || storageUnit == "grams")) {
      recipeValue *= 1000;
      recipeUnit = "g";
    }

    if (storageUnit == "l" && recipeUnit == "ml") {
      storageValue *= 1000;
      storageUnit = "ml";
    } else if (recipeUnit == "l" && storageUnit == "ml") {
      recipeValue *= 1000;
      recipeUnit = "ml";
    }

    return storageValue >= recipeValue && storageUnit == recipeUnit;
  }

  String findRecipeName(int id) => _recipes.firstWhere((r) => r["id"] == id, orElse: () => {"name": "Unknown"})["name"];

  dynamic findRecipe(int id) => _recipes.firstWhere((r) => r["id"] == id, orElse: () => null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analyser',
                  style: TextStyle(color: Colors.black),),
        backgroundColor: C.orange,
                iconTheme: IconThemeData(color: Colors.black),

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _analyse.length,
          itemBuilder: (context, index) {
            var entry = _analyse.entries.elementAt(index);
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Recepie(recipe: findRecipe(entry.key)),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 1.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orangeAccent,
                    child: Text((index + 1).toString(), style: TextStyle(color: Colors.white)),
                  ),
                  title: Text(findRecipeName(entry.key)),
                  subtitle: Text('${entry.value}%'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}