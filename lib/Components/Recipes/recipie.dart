import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'caloriesCalculator.dart';

class Recepie extends StatelessWidget {
  final Map<String, dynamic> recipe;

  Recepie({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 152, 0),
        toolbarHeight: 100,
        title: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Text(
            recipe["name"] ?? 'Recipe Details',
            style: TextStyle(fontSize: 20),
            maxLines: 4,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Aligns text to the start
          children: <Widget>[
            SizedBox(height: 20),
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
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8), // Adds space between texts
                    Text(
                      "Cooking time: ${recipe["cook_time"] ?? "Unknown"}",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8), // Adds space between texts
                    Text(
                      "Total time: ${recipe["total_time"] ?? "Unknown"}", // Fixed key from "cook_time" to "total_time"
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "TOTAL CALORIES: ${caloriesCalculator(recipe["ingredients"]).getCalories() ?? "Unknown"}", // Fixed key from "cook_time" to "total_time"
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            IngredientsSection(ingredients: recipe["ingredients"]),
            SizedBox(height: 8),
            Container(
                width: MediaQuery.sizeOf(context).width - 40,
                margin: const EdgeInsets.only(left: 20, top: 3, bottom: 20),
                decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.circular(16.0),
                  color: Color.fromARGB(255, 215, 184, 152),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._parseInstructions(recipe["instructions"] ?? ""),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
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

  IngredientsSection({required this.ingredients});

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: ingredients.map<Widget>((ingredient) {
            if (ingredient is Map<String, dynamic>) {
              return Container(
                margin: const EdgeInsets.only(left: 20, top: 3),
                child: Text(
                  "💥${(ingredient["amount"] ?? "").toString()} ${(ingredient["ingredient"] ?? "").toString()}",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            // Handle the case where ingredient is a string and split it
            if (ingredient is String) {
              var divided = ingredient.split(",");
              if (divided.length > 1) {
                var amount = divided[0].trim().split(" ");
                var ingredientName = divided[1].trim().split(" ");
                if (amount.length > 1) {
                  return Text(
                    "${amount[1]} ${ingredientName[1].trim()}",
                  );
                }
              }

              return Text("Invalid ingredient format");
            }

            return SizedBox
                .shrink(); // Return an empty widget for non-map items
          }).toList(),
        ),
      ),
    );
  }
}
