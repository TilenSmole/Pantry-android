import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'Components/Recipes/recipie.dart';
import 'package:http/http.dart' as http;
import 'Components/Recipes/add_recipe.dart';

class Recipies extends StatefulWidget {
  @override
  _RecipiesState createState() => _RecipiesState();
}

class _RecipiesState extends State<Recipies> {
  List _items = [];

  @override
  void initState() {
    super.initState();
    readLocalRecipes();
    fetchRecipes();
  }

  Future<void> readLocalRecipes() async {
    try {
      // Load the JSON file from assets
      final String response =
          await rootBundle.loadString('RECIPES/recipes.json');

      // Decode the JSON data
      final data = json.decode(response);

      // Update the state with the data
      setState(() {
        _items = data["Recipies"];
      });

      // Print the data to the console
      print('JSON Data: $_items');
    } catch (e) {
      print('Error loading JSON data: $e');
    }
  }

  Future<void> fetchRecipes() async {
    print("Fetching recipes..."); // Debug print statement

    try {
      final response =
          await http.get(Uri.parse('http://192.168.1.179:5000/recipes'));
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print('Raw JSON response2: ${data['Recipies']}');

        setState(() {
          _items +=    data['Recipies']; // Assign the recipes to your state variable
        });

        // Print the data to the console
        print('Fetched Recipes: ${data['Recipies']}');
      } else {
        // If the server returns an error, throw an exception
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      print('Error fetching recipes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Text(
            "Recipes",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          "here you can find all the available Recipies",
          style: TextStyle(fontSize: 15),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
              onTap: () {
                print("fadsf");

                setState(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddRecipe()),
                  );
                });
              },
              splashColor: Colors.green,
              highlightColor: Colors.blue,
              child: Column(children: [
                Icon(
                  Icons.add,
                  size: 40,
                  color: Colors.orange,
                ),
                Text("ADD A RECIPE")
              ])),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            children: <Widget>[
              for (var recipe in _items)
                InkWell(
                    onTap: () {
                      print(recipe);

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Recepie(recipe: recipe)));
                    },
                    child: Card(
                      child: Center(
                        child: Text(recipe["name"] ?? "unknown"),
                      ),
                    ))
            ],
          ),
        )
      ],
    ));
  }
}
