import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:http/http.dart' as http;
import '../load_token.dart' as load_token;

class AddRecipe extends StatefulWidget {
  @override
  _AddRecipeState createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _prep_timeController = TextEditingController();
  final TextEditingController _cook_timeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _recipeNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _ingreientController = TextEditingController();
  
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<String> _filteredSuggestions = [];
  List<String> _allSuggestions = [];
  List<String> _selectedFoods = [];
  String? token;

  @override
  void initState() {
    super.initState();
    _ingreientController.addListener(_updateSuggestions);
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
  }

  Future<void> setFood(String fileName, String key) async {
    print(key);
    try {
      // Load the JSON file from assets
      final String response = await rootBundle.loadString('FOODS/$fileName');

      // Decode the JSON response
      final Map<String, dynamic> data = json.decode(response);

      // Extract the list based on the provided key
      List<dynamic> items = data[key];

      // Extract item names, ensure the value is a String
      List<String> names = items.map((item) {
        return item["name"].toString(); // Change "name" if the key is different
      }).toList();

      // Update the state
      setState(() {
        _allSuggestions.addAll(names);
      });
  	  print(_allSuggestions );
      print("Loaded names from $fileName: $names"); // For debugging purposes
    } catch (e) {
      print('Error loading or parsing JSON: $e');
    }
  }

  void _updateSuggestions() {
    final query = _recipeNameController.text.toLowerCase();
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
    Overlay.of(context)!.insert(_overlayEntry!);
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
                        _recipeNameController.text =
                            _filteredSuggestions[index];
                        _selectedFoods.add('{amount: ${_amountController.text}, ingredient: ${_filteredSuggestions[index]} }');
                       _filteredSuggestions  =
                            []; // Clear suggestions after selection
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


  Future<void> uploadRecipe() async {
    try {
     print(_selectedFoods);
      final response = await http.post(
        Uri.parse('http://192.168.1.179:5000/recipes/add-recipe-mobile'),
        headers: { 'Authorization': 'Bearer ${token}',
          'Content-Type': 'application/json'},
        body:
            jsonEncode({'title': _nameController.text, 'ingredients': _selectedFoods,
            'instructions': _instructionsController.text, 'prep_time': _prep_timeController.text,
            'cook_time': _cook_timeController.text
            }),
      );

    

      print(response.statusCode);
      print(jsonDecode(response.body));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseJson = jsonDecode(response.body);

        // Extract the token from the JSON object
        final String? token = responseJson['token'];
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      print('Error fetching recipes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Recipe'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 65,
                  child: CompositedTransformTarget(
                    link: _layerLink,
                    child: TextFormField(
                      controller: _ingreientController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: 'Enter the name of the recipe',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 35,
                  child: TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter quantity',
                    ),
                  ),
                ),
              ],
            ),
            ..._selectedFoods
                .map((selected) => ListTile(
                      title: Text(selected),
                      // Optionally add more properties or actions
                    ))
                .toList(),
            TextFormField(
              controller: _prep_timeController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Enter prep time',
              ),
            ),
            TextFormField(
              controller: _cook_timeController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Enter cook time',
              ),
            ),
                TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Enter name',
              ),
            ),
            SizedBox(
              height: 120,
              child: TextField(
                controller: _instructionsController,
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Enter instructions',
                ),
              ),
            ),
            ElevatedButton(
              child: Text("Submit"),
              onPressed: () {
                uploadRecipe();
              },
            ),
          ],
        ),
      ),
    );
  }
}
