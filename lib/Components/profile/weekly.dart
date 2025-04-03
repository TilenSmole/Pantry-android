import 'package:flutter/material.dart';
import './API/weeklyAPI.dart' as API;
import '../load_token.dart' as load_token;
import '../RECIPES/API/recipeAPI.dart' as recipeAPI;
import '/Components/RECIPES/recipie.dart';
import '../HELPERS/colors.dart';

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
    _recipes = await API.fetchCostumRecipes(token, 7);
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
      appBar: AppBar(
        title: Text(
          "Weekly Planner",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 24, color: C.black),
        ),
        backgroundColor: C.orange,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: _recipes.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            addAll();
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 18),
                          backgroundColor: C.orange,
                          textStyle: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        child: Text(
                          "ADD ALL TO THE SHOPPING CART",
                          style: TextStyle(color: C.black),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _DisplayRecipes.length,
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            color: C.darkGrey,
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    days[i],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: C.orange,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          addedToSList[i]
                                              ? Icons.check_box
                                              : Icons.add_box,
                                          color: C.orange,
                                        ),
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
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit_note,
                                          color: C.orange,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            replaceRecipe(i);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              subtitle: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Recepie(
                                        recipe: _DisplayRecipes[i],
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  _DisplayRecipes[i]["name"] ?? "Unknown",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
