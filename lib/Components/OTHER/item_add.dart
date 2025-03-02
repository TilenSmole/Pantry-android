import 'package:flutter/material.dart';
// For rootBundle
import './API/item_add.dart' as API;

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
        title: Text('ADD A NEW ITEM'),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 20),
        child: Column(children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Enter items name',
            ),
            style: TextStyle(fontSize: 18),
          ),
          TextFormField(
            controller: _caloriesController,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Enter number of calories',
            ),
            style: TextStyle(fontSize: 18),
          ),
          TextFormField(
            controller: _proteinController,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Enter protein per 100g',
            ),
          ),
          TextFormField(
            controller: _fatController,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Enter fat per 100g',
            ),
          ),
          TextFormField(
            controller: _fiberController,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Enter fiber per 100g',
            ),
          ),
          TextFormField(
            controller: _carbonsController,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Enter carbohydrates per 100g',
            ),
          ),
          TextFormField(
            controller: _sugarController,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Enter sugar per 100g',
            ),
          ),
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
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
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
                  carbohydrates: double.tryParse(_carbonsController.text) ?? 0.0,
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