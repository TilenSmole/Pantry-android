import 'dart:async';
import 'package:flutter/material.dart';
// For rootBundle
import '../load_ingredients.dart';
import '../../colors.dart';

class selectCriteria extends StatefulWidget {
  @override
  _selectCriteriaState createState() => _selectCriteriaState();
}

class _selectCriteriaState extends State<selectCriteria> {
  List<String> _allSuggestions = [];
  List<bool> _checkedValues = [];
  static List<String> _selectedValues = [];

  @override
  void initState() {
    super.initState();

    loadFood();
  }

  Future<void> loadFood() async {
    IngredientLoader loader = IngredientLoader();
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _allSuggestions = loader.allSuggestions;
      _checkedValues = List<bool>.filled(_allSuggestions.length, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SELECT ITEMS'),
      ),
      body: _allSuggestions.isEmpty
          ? Center(
              child:
                  CircularProgressIndicator()) // Show a loading indicator until data is available
          : ListView.builder(
              itemCount: _allSuggestions.length,
              itemBuilder: (context, i) {
                return CheckboxListTile(
                  key: ValueKey(i),
                  title: Text(_allSuggestions[i]),
                  value: _checkedValues[i],
                  onChanged: (bool? newValue) {
                    setState(() {
                      _checkedValues[i] = newValue ?? false;
                      if (_checkedValues[i] == true) {
                        _selectedValues.add(_allSuggestions[i]);
                      } else if (_checkedValues[i] == false &&
                          _selectedValues.contains(_allSuggestions[i])) {
                        _selectedValues.remove(_allSuggestions[i]);
                      }
                      print(_selectedValues);
                    });
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                );
              }),
      bottomNavigationBar: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextButton(
              style: ButtonStyle(
                foregroundColor:
                    WidgetStateProperty.all<Color>(Colors.orange),
              ),
              onPressed: () {
                setState(() {
                  _selectedValues = [];
                  _checkedValues =
                      List<bool>.filled(_allSuggestions.length, false);
                });
              },
                child: Text(
                          'Reset',
                          style: TextStyle(color: C.orange),
                        ),
            ),
          ),
          TextButton(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all<Color>(Colors.orange),
            ),
            onPressed: () {
              Navigator.pop(context, _selectedValues);
            },
                  child: Text(
                          'Confirm',
                          style: TextStyle(color: C.orange),
                        ),
          ),
        ],
      ),
    );
  }
}
