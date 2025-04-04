import 'package:flutter/material.dart';
import './API/item_add.dart' as API;
import '../HELPERS/colors.dart';
import '../HELPERS/get_categories.dart';

class FoodDetailScreen extends StatefulWidget {
  final Map<String, dynamic> food;
  late final  bool checked;
  late final  int index;

  FoodDetailScreen({
    super.key,
    required this.food,
    required this.checked,
    required this.index,
  });

  @override
  FoodDetailScreenState createState() => FoodDetailScreenState();
}

class FoodDetailScreenState extends State<FoodDetailScreen> {
  List<String> categories = [];
  late TextEditingController _controllersWarning;

  @override
  void initState() {
    super.initState();
    fetchCategories();

    String warningRaw = (widget.food["UserStorageDefaults"]?.isEmpty ?? true)
        ? "0"
        : widget.food["UserStorageDefaults"]?[0]["warning"] ?? "0";

    final numberMatch = RegExp(r'^(\d+(?:\.\d+)?)').firstMatch(warningRaw);
    int warningValue =
        numberMatch != null ? int.parse(numberMatch.group(1)!) : 0;

    _controllersWarning = TextEditingController(
      text: warningValue > 0 ? warningRaw.toString() : "",
    );
  }

  Future<void> fetchCategories() async {
    List<String> fetchedCategories = await GetCategories.fetchCategories();
    setState(() {
      categories = fetchedCategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: C.orange,
        title: Text(
          widget.food["name"],
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 24, color: C.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: C.darkGrey,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
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
                      Text(
                        "Ne shranjuj v shrambo",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  _buildNutritionInfo(
                      "Calories", widget.food["calories"].toString()),
                  _buildNutritionInfo("Fat", "${widget.food["fat"]}g"),
                  _buildNutritionInfo(
                      "Carbs", "${widget.food["carbohydrates"]}g"),
                  _buildNutritionInfo("Sugar", "${widget.food["sugar"]}g"),
                  _buildNutritionInfo("Proteins", "${widget.food["protein"]}g"),
                  _buildNutritionInfo("Fiber", "${widget.food["fiber"]}g"),
                  //   _buildNutritionInfo("Allergies", widget.food["allergens"]),
                  _buildNutritionInfo(
                      "Is Vegan", widget.food["isVegan"] ? "Yes" : "No"),
                  _buildNutritionInfo("Is Vegetarian",
                      widget.food["isVegetarian"] ? "Yes" : "No"),
                  SizedBox(height: 20),
                  _buildNutritionInfo(
                    "Default storage:",
                    widget.food["UserStorageDefaults"]?.isEmpty == true
                        ? "Default"
                        : widget.food["UserStorageDefaults"]?[0]
                                    ["defaultStorageCategory"]
                                ?.toString() ??
                            "Default",
                  ),
                  Text(
                    "Set default location storage:",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  DropdownButton<String>(
                    dropdownColor: C.darkGrey,
                    items: categories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) async {
                      if (newValue != null) {
                        var code = await API.changeDefaultCategory(
                            widget.food["id"], newValue);
                        if (code == 200) {
                          setState(() {
                            widget.food["UserStorageDefaults"]?[0]
                                ["defaultStorageCategory"] = newValue;
                          });
                        }
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Set warnings",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          controller: _controllersWarning,
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () {
                          setState(() {
                            API.setWarning(
                                widget.food["id"], _controllersWarning.text);
                          });
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
