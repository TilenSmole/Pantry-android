import 'package:flutter/material.dart';
import 'Components/RECIPES/recipie.dart';
import 'Components/RECIPES/add_recipe.dart';
import 'Components/RECIPES/selectCriteria.dart';
import 'Components/RECIPES/API/recipes.API.dart' as API;
import 'colors.dart';

class Recipies extends StatefulWidget {
  @override
  _RecipiesState createState() => _RecipiesState();
}

class _RecipiesState extends State<Recipies> {
  List<dynamic> _recipes = [];
  List<dynamic> _DisplayRecipes = [];

  static List<String> _selectedValues = [];

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    fetchRecipes();
    _searchController.addListener(_updateSuggestions);
  }

  void _updateSuggestions() {
    print("Updating suggestions");
    setState(() {
      String inputText = _searchController.text.toLowerCase();
      _DisplayRecipes = [];

      if (inputText.isEmpty) {
        _DisplayRecipes = _recipes;
      } else {
        _DisplayRecipes = _recipes
            .where((recipe) =>
                recipe["name"].toLowerCase().contains(inputText.toLowerCase()))
            .toList();

        for (var recipe in _recipes) {
          for (var ingredient in recipe["ingredients"]) {
            if (ingredient.toLowerCase().contains(inputText..toLowerCase())) {
              if (!_DisplayRecipes.contains(recipe)) {
                _DisplayRecipes.add(recipe);
              }
            }
          }
        }
      }
    });
    // _showOverlay(mapId, itemId);
  }

  void _updateSuggestionsIngredients() {
    print("Updating _updateSuggestionsIngredients");
    _DisplayRecipes = [];
    for (var item in _selectedValues) {
      for (var recipe in _recipes) {
        for (var ingredient in recipe["ingredients"]) {
          if (item.toLowerCase() == ingredient.toLowerCase()) {
            if (!_DisplayRecipes.contains(recipe)) {
              _DisplayRecipes.add(recipe);
            }
          }
        }
      }
    }
  }

  Future<void> fetchRecipes() async {
    _recipes = await API.fetchRecipes(); //API.getStorageLocal();//s

    setState(() {
      _DisplayRecipes = _recipes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _recipes.isEmpty
            ? Center(
                child:
                    CircularProgressIndicator()) // Show a loading indicator until data is available
            : Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 20, right: 20, top: 40),
                    child: TextFormField(
                        focusNode: _searchFocusNode,
                        controller: _searchController,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Search',
                          suffixIcon: Icon(Icons.search),
                        )),
                  ),
                  Row(
                    children: [
                      TextButton(
                        style: ButtonStyle(
                          foregroundColor:
                              WidgetStateProperty.all<Color>(Colors.blue),
                        ),
                        onPressed: () async {
                          // Await the result from the selectCriteria screen
                          final result = await Navigator.push<List<String>>(
                            context,
                            MaterialPageRoute(
                                builder: (context) => selectCriteria()),
                          );

                          if (result != null) {
                            setState(() {
                              _selectedValues = result; // Update selected items
                            });
                            _updateSuggestionsIngredients();
                            print("Selected items: $_selectedValues");
                          }
                        },
                           child: Text(
                          'Advanced search',
                          style: TextStyle(color: C.lightBlue),
                        ),
                      ),
                      TextButton(
                        style: ButtonStyle(
                          foregroundColor:
                              WidgetStateProperty.all<Color>(Colors.blue),
                        ),
                        onPressed: () {
                          setState(() {
                            _DisplayRecipes = _recipes;
                            _searchController.text = "";
                            _searchFocusNode.unfocus();
                            _selectedValues = [];
                          });
                        },
                        child: Text(
                          'Clear parameters',
                          style: TextStyle(color: C.lightBlue),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3,
                      children: <Widget>[
                        for (var recipe in _DisplayRecipes)
                          InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Recepie(recipe: recipe)));
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 2, right: 2),
                                child: Card(
                                  color: C.lightBlue,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(recipe["name"] ?? "unknown"),
                                    ),
                                  ),
                                ),
                              ))
                      ],
                    ),
                  )
                ],
              ),
        floatingActionButton: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddRecipe()),
            );
          },
          child: Container(
              height: 75.0,
              width: 75.0,
              decoration: BoxDecoration(
                color: C.orange,
                shape: BoxShape.circle, // Make the container circular
              ),
              child: Center(
                child: Icon(
                  Icons.add,
                  size: 40,
                ),
              )),
        ));
  }
}
