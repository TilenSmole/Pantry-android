import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Recepie extends StatelessWidget {
  final Map<String, dynamic> recipe;

  Recepie({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(recipe["ingredients"]);
    print(recipe["ingredients"].length);
    print("recipe[ingredients.runtimeType");

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              recipe["name"] ?? 'Recipe Details',
              maxLines: 4, // Allow up to 2 lines
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Aligns text to the start
          children: <Widget>[
            Text(
              "Preparation time: ${recipe["prep_time"] ?? "Unknown"}",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8), // Adds space between texts
            Text(
              "Cooking time: ${recipe["cook_time"] ?? "Unknown"}",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8), // Adds space between texts
            Text(
              "Total time: ${recipe["total_time"] ?? "Unknown"}", // Fixed key from "cook_time" to "total_time"
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
             if (recipe["ingredients"] is List<dynamic>)
              ...(
                recipe["ingredients"] as List<dynamic>
              ).map<Widget>(
                (ingredient) {
                  if (ingredient is Map<String, dynamic>) {
                    return Text(
                      "${(ingredient["amount"]  ?? "").toString()} ${(ingredient["ingredient"] ?? "").toString()}",
                    );
                  }
                       var divided = ingredient.split(",");
                    if (divided.length > 1) {
                      var amount = divided[0].trim().split(" ");
                     var ingredient = divided[1].trim().split(" ");
                      if (amount.length > 1) {
                        return Text(
                          "${amount[1]} ${ingredient[1].trim()}",
                        );
                      }
                    }
                  
                  return Text("Invalid ingredient format");
                },
                  
              ).toList(),
            SizedBox(height: 8),
            Text(
              "Instructions: ${recipe["instructions"] ?? "Unknown"}",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
