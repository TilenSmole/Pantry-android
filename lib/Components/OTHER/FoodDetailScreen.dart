import 'package:flutter/material.dart';
import './API/item_add.dart' as API;


class FoodDetailScreen extends StatefulWidget {
  final Map<String, dynamic> food;
  bool checked = false;
  int index = 0;
  
  FoodDetailScreen({
    super.key,
    required this.food,
    required this.checked,
    required this.index,
  });

  @override
  _FoodDetailScreenState createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  List<String> categories = [] ;


  @override
  void initState() {
    super.initState();
    fetchData();
  }
  Future<void> fetchData() async {
    List<dynamic> categorieData = await API.getCategories();

   setState(() {
      categories = categorieData.map((category) => category['category'] as String).toList();
      categories.add("Default");
      categories.add("Freezer");
    });


  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.food["name"])), 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                            Checkbox(
              value: widget.checked,
              onChanged: (bool? value) async {
                await API.setDisallowdItems(widget.index, value);
               setState(() {
                  widget.checked = value ?? false;  
                });
                
              },
            ),
            Text("Ne shranjuj v shrambo"),
              ],
            ),

            Text("Calories: ${widget.food["calories"]}", style: TextStyle(fontSize: 18)),
            Text("Fat: ${widget.food["fat"]}g", style: TextStyle(fontSize: 18)),
            Text("Carbs: ${widget.food["carbohydrates"]}g", style: TextStyle(fontSize: 18)),
            Text("Sugar: ${widget.food["sugar"]}g", style: TextStyle(fontSize: 18)),
            Text("Proteins: ${widget.food["protein"]}g", style: TextStyle(fontSize: 18)),
            Text("Fiber: ${widget.food["fiber"]}g", style: TextStyle(fontSize: 18)),
            Text("Allergies: ${widget.food["allergens"]}", style: TextStyle(fontSize: 18)),   
            Text("Is Vegan: ${widget.food["isVegetarian"] ? "Yes" : "No"}", style: TextStyle(fontSize: 18)),
            Text("Is Vegan: ${widget.food["isVegan"] ? "Yes" : "No"}", style: TextStyle(fontSize: 18)),


            Text("Default lokacija za shranjevanje"),
              DropdownButton<String>(
                items: categories.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  API.changeDefaultCategory(widget.index, newValue);  
                },
              ),
            Text("Nastavi opomnik, ko je izdelka malo"),


          ],
         



        ),
      ),
    );
  }
}
