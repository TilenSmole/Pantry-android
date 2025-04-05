import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:pantry_app/storage.dart';
import '../load_token.dart' as load_token;
import '../HELPERS/colors.dart';
import '../HELPERS/get_categories.dart';
import './API/storage_api.dart' as API;

class AddStorageItem extends StatefulWidget {
  @override
  AddStorageState createState() => AddStorageState();
}

class AddStorageState extends State<AddStorageItem> {
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String selectedCategory = "Default";
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<String> _filteredSuggestions = [];
  List<String> _allSuggestions = [];
  List<String> categories = [];

  String? token;

  @override
  void initState() {
    super.initState();
    _ingredientController.addListener(_updateSuggestions);
    setFood('Vegetables.json', 'vegetables');
    setFood('Fruits.json', 'fruits');
    setFood('Condiments.json', 'condiments');
    setFood('Dairy.json', 'dairy');
    setFood('Grains.json', 'grains');
    setFood('Legumes.json', 'legumes');
    setFood('Meat.json', 'meat');
    setFood('Nuts and Seeds.json', 'nuts');
    setFood('Seafood.json', 'seafood');
    setFood('Spices and Herbs.json', 'spicesHerbs');
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _removeOverlay();
      } else {
        _showOverlay();
      }
    });
    _loadToken();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    List<String> fetchedCategories = await GetCategories.fetchCategories();
    setState(() {
      categories = fetchedCategories;
    });
  }

  Future<void> setFood(String fileName, String key) async {
    try {
      final String response = await rootBundle.loadString('FOODS/$fileName');

      final Map<String, dynamic> data = json.decode(response);

      List<dynamic> items = data[key];

      List<String> names = items.map((item) {
        return item["name"].toString();
      }).toList();

      setState(() {
        _allSuggestions.addAll(names);
      });
      print(_allSuggestions);
      print("Loaded names from $fileName: $names"); // For debugging purposes
    } catch (e) {
      print('Error loading or parsing JSON: $e');
    }
  }

  void _updateSuggestions() {
    final query = _ingredientController.text.toLowerCase();
    setState(() {
      _filteredSuggestions = _allSuggestions.where((suggestion) {
        return suggestion.toLowerCase().contains(query);
      }).toList();
    });

    if (_filteredSuggestions.isNotEmpty) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, 60), // Adjust the vertical offset as needed
          child: Material(
            elevation: 4.0,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 200, // Maximum height for the suggestions list
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredSuggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_filteredSuggestions[index]),
                    onTap: () {
                      setState(() {
                        _ingredientController.text =
                            _filteredSuggestions[index];

                        // _selectedFoods.add(
                        //   '{amount: ${_amountController.text}, ingredient: ${_filteredSuggestions[index]} }');
                        _filteredSuggestions =
                            []; // Clear suggestions after selection
                        _amountController.text = "";
                      });
                      _removeOverlay();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadToken() async {
    final loadedToken = await load_token.loadToken();
    setState(() {
      token = loadedToken;
    });
  }

  Future<void> addANewItem() async {
      API.addANewItem(_amountController.text, _ingredientController.text, selectedCategory);
             Navigator.push(  
              context,
              MaterialPageRoute(builder: (context) => Storage()),
            );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add a New Recipe',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: C.orange,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
              color: C.darkGrey,
              borderRadius: BorderRadius.all(Radius.circular(15))),
          margin: const EdgeInsets.all(10.0),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                    Row(
                  children: [
                    Expanded(
                      child: CompositedTransformTarget(
                        link: _layerLink,
                        child: TextFormField(
                          controller: _ingredientController,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            hintText: 'Enter the ingredient',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          hintText: 'quantity',
                        ),
                      ),
                    ),
                  ],
                ),
                                  SizedBox(height: 20),

              
                Row(children: [Text(
                    "Storage location:  ",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                DropdownButton<String>(
                  dropdownColor: C.darkGrey,
                  value:selectedCategory,
                  items: categories.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                    }
                  },
                ),],),
                 
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: C.orange,
                        foregroundColor: Colors.black,
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                        textStyle: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    child: Text("SUBMIT"),
                    onPressed: () {
                       addANewItem();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
