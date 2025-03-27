import 'package:flutter/material.dart';
// For rootBundle
import './API/item_add.dart' as API;
import '../HELPERS/colors.dart';
import '../HELPERS/inputField.dart';

class AddItem extends StatefulWidget {
  @override
  _addItemState createState() => _addItemState();
}

class _addItemState extends State<AddItem> {
  String? token;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _carbonsController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();

  final TextEditingController _fiberController = TextEditingController();
  final TextEditingController _sugarController = TextEditingController();

  final TextEditingController _caloriesController = TextEditingController();

  bool isVegan = false;
  bool isVegetarian = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Food',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: C.orange,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
        child: Column(children: [
          CustomTextFormField(
            controller: _nameController,
            labelText: 'item name',
          ),
          CustomTextFormField(
            controller: _caloriesController,
            labelText: 'calories/100g',
          ),
          CustomTextFormField(
            controller: _proteinController,
            labelText: 'protein/100g',
          ),
          CustomTextFormField(
            controller: _fatController,
            labelText: 'fat/100g',
          ),
          CustomTextFormField(
            controller: _fiberController,
            labelText: 'fiber/100g',
          ),
          CustomTextFormField(
            controller: _carbonsController,
            labelText: 'carbs/100g',
          ),
          CustomTextFormField(
            controller: _sugarController,
            labelText: 'sugar/100g',
          ),
          Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Suitable for vegetarians: ',
                        style: TextStyle(fontSize: 17.0),
                      ),
                      Checkbox(
                        tristate: true,
                        value: isVegetarian,
                        onChanged: (bool) {
                          setState(() {
                            isVegetarian = !isVegetarian;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        'Suitable for vegans : ',
                        style: TextStyle(fontSize: 17.0),
                      ),
                      Checkbox(
                        tristate: true,
                        value: isVegan,
                        onChanged: (bool) {
                          setState(() {
                            isVegan = !isVegan;
                          });
                        },
                      )
                    ],
                  ),
                ],
              )),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: C.orange,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              child: Text("SUBMIT"),
              onPressed: () {
                API.addItem(
                  name: _nameController.text,
                  calories: double.tryParse(_caloriesController.text) ?? 0.0,
                  protein: double.tryParse(_proteinController.text) ?? 0.0,
                  fat: double.tryParse(_fatController.text) ?? 0.0,
                  carbohydrates:
                      double.tryParse(_carbonsController.text) ?? 0.0,
                  fiber: double.tryParse(_fiberController.text) ?? 0.0,
                  sugar: double.tryParse(_sugarController.text) ?? 0.0,
                  isVegan: isVegan,
                  isVegetarian: isVegetarian,
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
