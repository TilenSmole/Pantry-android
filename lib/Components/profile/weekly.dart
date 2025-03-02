import 'package:flutter/material.dart';
import './API/weeklyAPI.dart' as API;
import '../load_token.dart' as load_token;
import '../RECIPES/API/recipeAPI.dart' as recipeAPI;
import '/Components/RECIPES/recipie.dart';

class Weekly extends StatefulWidget {
  @override
  _WeekyState createState() => _WeekyState();
}

class _WeekyState extends State<Weekly> {
  List<dynamic> _recipes = [];
  List<dynamic> _DisplayRecipes = [];
  List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  String? token;

  List<bool> addedToSList = [];
  bool addedAll = false;

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

    fetchCostumRecipes();
  }

  Future<void> fetchCostumRecipes() async {
    _recipes = await API.fetchCostumRecipes(token, 7); //API.getStorageLocal();

    setState(() {
      _DisplayRecipes = _recipes;
      addedToSList = List.filled(_recipes.length, false);
    });
  }

  Future<void> replaceRecipe(position) async {
    var updatedRecipies = await API.replace(token, position);

    setState(() {
      _DisplayRecipes = updatedRecipies;
    });
  }

  Future<void> addAll() async {
    for (var i = 0; i < _DisplayRecipes.length; i++) {
      int? result = await recipeAPI.addToSList(
          _DisplayRecipes[i]["ingredients"],
          _DisplayRecipes[i]["amounts"],
          token!);
      if (result == 0) {
        setState(() {
          addedToSList[i] = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _recipes.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Text(
                      "PLANNER",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            addAll();
                          });
                        },
                        child: Text("ADD ALL TO THE SHOPPING CART"),
                      )
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      for (var i = 0; i < _DisplayRecipes.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, right: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Text(
                                        days[i],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      //add to shopping cart
                                      IconButton(
                                        icon: Icon(addedToSList[i]
                                            ? Icons.check_box
                                            : Icons.add_box),
                                        onPressed: () async {
                                          int? result =
                                              await recipeAPI.addToSList(
                                                  _DisplayRecipes[i]
                                                      ["ingredients"],
                                                  _DisplayRecipes[i]["amounts"],
                                                  token!);
                                          if (result == 0) {
                                            setState(() {
                                              addedToSList[i] = true;
                                            });
                                          }
                                        },
                                      ),
                                      //replace this recipy with a new one
                                      IconButton(
                                        icon: Icon(Icons.edit_note),
                                        onPressed: () {
                                          setState(() {
                                            replaceRecipe(i);
                                          });
                                        },
                                      ),
                                    ]),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Recepie(
                                                recipe: _DisplayRecipes[i]),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        _DisplayRecipes[i]["name"] ?? "unknown",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  )
                ],
              ),
        floatingActionButton: GestureDetector(
          onTap: () {
            /* Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddRecipe()),
            );*/
          },
          child: Container(
              height: 75.0,
              width: 75.0,
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle, // Make the container circular
              ),
              child: Center(
                child: Icon(
                  Icons.add,
                  size: 40,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              )),
        ));
  }
}
