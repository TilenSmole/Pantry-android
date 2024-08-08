import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'caloriesCalculator.dart';
import './API/recipeAPI.dart' as API;
import '../load_token.dart' as load_token;

class Recepie extends StatefulWidget {
  final Map<String, dynamic> recipe;
  Recepie({Key? key, required this.recipe}) : super(key: key);
  @override
  State<StatefulWidget> createState() => RecepieState(recipe);
}

class RecepieState extends State<Recepie> {
  final Map<String, dynamic> recipe;
  RecepieState(this.recipe);
  String? token;
  bool addedToList = false;

  Future<void> _loadToken() async {
    final loadedToken = await load_token.loadToken();
    setState(() {
      token = loadedToken;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 255, 152, 0),
          toolbarHeight: 100,
          title: Text(
            recipe["name"] ?? 'Recipe Details',
            style: TextStyle(fontSize: 20),
            maxLines: 2, // Limit to a sensible number of lines
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Aligns text to the start
                  children: <Widget>[
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 17.0, bottom: 10),
                      child: Row(
                        children: [
                          CircularOrangeButton(
                            icon: Icons.archive,
                            onPressed: () {
                              // Handle button press
                            },
                          ),
                          CircularOrangeButton(
                            icon: Icons.edit,
                            onPressed: () {
                              // Handle button press
                            },
                          ),
                          CircularOrangeButton(
                            icon: Icons.notes,
                            onPressed: () {
                              // Handle button press
                            },
                          ),
                          CircularOrangeButton(
                            icon: Icons.add,
                            onPressed: () {
                              // Handle button press
                            },
                          ),
                          !addedToList
                              ? CircularOrangeButton(
                                  icon: Icons.add_box,
                                  onPressed: () async {
                                    print(recipe);
                                    int? result = await API.addToSList(
                                        recipe["ingredients"],
                                        recipe["amounts"],
                                        token!);
                                    print(result);
                                    if (result == 0) {
                                      setState(() {
                                        addedToList = true;
                                      });
                                    }
                                  },
                                )
                              : CircularOrangeButton(
                                  icon: Icons.done,
                                  onPressed: () {},
                                ),
                          CircularOrangeButton(
                            icon: Icons.share,
                            onPressed: () {
                              // Handle button press
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 20, top: 3),
                      decoration: new BoxDecoration(
                        borderRadius: new BorderRadius.circular(16.0),
                        color: Color.fromARGB(255, 215, 184, 152),
                      ),
                      width: MediaQuery.sizeOf(context).width - 40,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Preparation time: ${recipe["prep_time"] ?? "Unknown"}",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 8), // Adds space between texts
                            Text(
                              "Cooking time: ${recipe["cook_time"] ?? "Unknown"}",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 8), // Adds space between texts
                            Text(
                              "Total time: ${recipe["total_time"] ?? "Unknown"}", // Fixed key from "cook_time" to "total_time"
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "TOTAL CALORIES: ${caloriesCalculator(recipe["ingredients"]).getCalories() ?? "Unknown"}", // Fixed key from "cook_time" to "total_time"
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    IngredientsSection(
                        ingredients: recipe["ingredients"],
                        amounts: recipe["amounts"]),
                    SizedBox(height: 8),
                    Container(
                        width: MediaQuery.sizeOf(context).width - 40,
                        margin:
                            const EdgeInsets.only(left: 20, top: 3, bottom: 20),
                        decoration: new BoxDecoration(
                          borderRadius: new BorderRadius.circular(16.0),
                          color: Color.fromARGB(255, 215, 184, 152),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ..._parseInstructions(
                                  recipe["instructions"] ?? ""),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: GestureDetector(
          onTap: () {},
          child: Container(
              height: 60.0,
              width: 60.0,
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle, // Make the container circular
              ),
              child: Center(
                child: Icon(
                  Icons.microwave,
                  size: 20,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              )),
        ));
  }
}

List<Widget> _parseInstructions(String instructions) {
  List<String> instructionList =
      instructions.split('.').where((s) => s.trim().isNotEmpty).toList();

  return instructionList.map((instruction) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, left: 20.0),
      child: Text(
        "${instruction.trim()}.",
        style: TextStyle(fontSize: 20),
      ),
    );
  }).toList();
}

class IngredientsSection extends StatelessWidget {
  final List<dynamic> ingredients;
  final List<dynamic> amounts;

  IngredientsSection({required this.ingredients, required this.amounts});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, top: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: Color.fromARGB(255, 215, 184, 152),
      ),
      width: MediaQuery.sizeOf(context).width - 40,
      child: Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        
          for (var i = 0; i < ingredients.length; i++)
            Container(
              margin: const EdgeInsets.only(left: 20, top: 3),
              child: Text(
                "${amounts[i] != null ? amounts[i] : ""} x ${ingredients[i]  != null ? ingredients[i] : ""}",
                style: TextStyle(fontSize: 16),
              ),
            ),
        ]),
      ),
    );
  }
}

class CircularOrangeButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  CircularOrangeButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 215, 184, 152),
          shape: BoxShape.circle, // Circular shape
        ),
        child: IconButton(
          icon: Icon(icon,
              size: 25.0, color: Colors.white), // White icon color for contrast
          onPressed: onPressed,
        ),
      ),
    );
  }
}
