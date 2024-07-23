import 'package:flutter/material.dart';

class Recepie extends StatelessWidget {
  final Map recipe;

  Recepie({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        )),
        body: SingleChildScrollView(
            child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Aligns text to the start
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
              "Total time: ${recipe["total_time"] ?? "Unknown"}",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
              if (recipe["ingredients"] is List)
              ...(
                recipe["ingredients"] as List
              ).map(
                (ingredient) {
                  // Assuming each ingredient is a map with "amount" and "ingredient"
                    return Text("${ingredient["amount"] ?? ""} ${ingredient["ingredient"] ?? ""}");
                },
              ),
            SizedBox(height: 8),
            if (recipe["instructions"] is List)
              ...(recipe["instructions"] as List).map(
                (instruction) {
                  if (instruction is String) {
                    return Text(instruction);
                  } else {
                    return Text("Invalid instruction data");
                  }
                },
              ),
          ],
        )));
  }
}
