import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Components/load_token.dart' as load_token;
import 'dart:convert';
import './Components/load_ingredients.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ShoppingCart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CreateShoppingCartState();
}

class CreateShoppingCartState extends State<ShoppingCart> {
  List shopping_cart = [];
  LayerLink _newLayerController = LayerLink();
  TextEditingController _newItemController = TextEditingController();
  TextEditingController _newQtntyItemController = TextEditingController();
  Map<int, TextEditingController> _controllersQTY = {};
  Map<int, TextEditingController> _controllersITM = {};
  Map<int, FocusNode> _focusNodesQTY = {};
  Map<int, FocusNode> _focusNodesITM = {};
  Map<String, List<String>> suggestions = {};
  List<String> _filteredSuggestions = [];
  List<String> _allSuggestions = [];
  List<String> _selectedFoods = [];
  var openInput = false;
  var openText = true;
  final FocusNode _focusNode = FocusNode();
  String? token;
  OverlayEntry? _overlayEntry;
  Map<int, LayerLink> _layerLinks = {};
  late ScrollController _scrollController;
  @override
  void initState() {
            _newItemController.addListener(_updateSuggestions2);
    _scrollController = ScrollController();
    super.initState();
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
    _loadToken().then((_) {
      getItems();
    });
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
          _removeOverlay();
      } else {
        openInputTypingField();
                _showOverlay2();

      }
    });
    _layerLinks[-1] = LayerLink();
    loadFood();

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
      // print(_allSuggestions);
      //print("Loaded names from $fileName: $names"); // For debugging purposes
    } catch (e) {
      print('Error loading or parsing JSON: $e');
    }
  }

  void _showOverlay(int itemId) {
    print("Showing overlay");
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }
    _overlayEntry = _createOverlayEntry(itemId);
    Overlay.of(context)?.insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry(int itemId) {
    if (!_layerLinks.containsKey(itemId)) {
      print("LayerLink for itemId $itemId is missing");
      return OverlayEntry(
          builder: (context) => Text(
              "data") // SizedBox.shrink(), // Empty widget if link is missing
          );
    }
    print("creating overlay");

    LayerLink link = _layerLinks[itemId]!;
    return OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width,
        child: CompositedTransformFollower(
          link: link,
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
                        print(_controllersITM[itemId]?.text);
                        _controllersITM[itemId]?.text =
                            _filteredSuggestions[index];
                        _filteredSuggestions =
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
void _showOverlay2() {
    print("Showing overlay");
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }
    _overlayEntry = _createOverlayEntry2();
    Overlay.of(context)?.insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry2() {
  
    print("creating overlay");

    LayerLink link =  _newLayerController;
    return OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width,
        child: CompositedTransformFollower(
          link: link,
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
                        _newItemController.text =
                            _filteredSuggestions[index];
                        _filteredSuggestions =
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
  Future<void> loadFood() async {
    IngredientLoader loader = IngredientLoader();
    await Future.delayed(Duration(seconds: 1)); // Give it some time to load
    suggestions = loader.allSuggestions;
  }

  Future<void> updateItem(int index, String id) async {
    try {
      // Extract values as strings
      var amount = _controllersQTY[index]?.text ?? '';
      var ingredient = _controllersITM[index]?.text ?? '';

      final response = await http.put(
        Uri.parse(
            'http://192.168.1.179:5000/shopping-list/update-a-shopping-list-mobile'),
        headers: {
          'Authorization': 'Bearer ${token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'item': '["amount: ${amount}", "ingredient: ${ingredient} "]',
          'id': id
        }),
      );

      if (response.statusCode == 200) {
        print("Update successful");
      } else {
        throw Exception('Failed to update item');
      }
    } catch (e) {
      print('Error updating item: $e');
    }
  }

  Future<void> _loadToken() async {
    final loadedToken = await load_token.loadToken();
    setState(() {
      token = loadedToken;
    });
  }

  Future<void> getItems() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.1.179:5000/shopping-list/get-users-shopping-list-mobile'),
        headers: {
          'Authorization': 'Bearer ${token}',
          'Content-Type': 'application/json'
        },
      );

      //   print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        setState(() {
          shopping_cart = data["items"];

          _controllersQTY = Map.fromIterable(
            shopping_cart,
            key: (item) => item['id'] as int,
            value: (item) {
              var itemText = item['item'] ?? '';
              var amountText = '';

              // Safely parse amount from the item text
              if (itemText.contains(',')) {
                var parts = itemText.split(',');
                if (parts.length > 1) {
                  var amountPart = parts[0].split(' ');
                  if (amountPart.length > 1) {
                    amountText = amountPart[1].replaceAll('"', '');
                  }
                }
              }
              var controller = TextEditingController(text: amountText);

              //  print(
              //      'Initialized _controllersQTY[${item['id']}] with text: ${controller.text}');
              return controller;
            },
          );

          _controllersITM = Map.fromIterable(
            shopping_cart,
            key: (item) => item['id'] as int,
            value: (item) {
              var itemText = item['item'] ?? '';
              var ingredientText = '';

              // Safely parse ingredient from the item text
              if (itemText.contains(',')) {
                var parts = itemText.split(',');
                if (parts.length > 1) {
                  var ingredientPart = parts[1].trim().split(' ');
                  if (ingredientPart.length > 1) {
                    ingredientText = ingredientPart[1];
                  }
                }
              }

              var controller = TextEditingController(text: ingredientText);
              controller.addListener(() => _updateSuggestions(item['id']));
              //   print(
              //       'Initialized _controllersITM[${item['id']}] with text: ${controller.text}');
              return controller;
            },
          );

          _focusNodesQTY = Map.fromIterable(
            shopping_cart,
            key: (item) => item['id'] as int,
            value: (item) {
              var focusNode = FocusNode();
              focusNode.addListener(() {
                if (!focusNode.hasFocus) {
                  updateItem(item['id'], item['id'].toString());
                }
              });
              return focusNode;
            },
          );

          _focusNodesITM = Map.fromIterable(
            shopping_cart,
            key: (item) => item['id'] as int,
            value: (item) {
              var focusNode = FocusNode();

              focusNode.addListener(() {
                if (!focusNode.hasFocus) {
                  updateItem(item['id'], item['id'].toString());
                }
              });

              return focusNode;
            },
          );

          _layerLinks = {
            for (var item in shopping_cart) item['id'] as int: LayerLink()
          };
        });
        print(_layerLinks);
        print("_layerLinks");

        //  print(data["items"]);
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      print('Error fetching items: $e');
    }
  }

  void _updateSuggestions(int itemId) {
    print("Updating suggestions");
    setState(() {
      String inputText = _controllersITM[itemId]?.text.toLowerCase() ?? '';
      if (inputText.isEmpty) {
        _filteredSuggestions = [];
      } else {
        _filteredSuggestions = _allSuggestions
            .where((suggestion) => suggestion.toLowerCase().contains(inputText))
            .toList();
      }
    });
    _showOverlay(itemId); // Show the overlay with the itemId's layer link
  }
 void _updateSuggestions2() {
    print("Updating suggestions");
    setState(() {
      String inputText = _newItemController.text.toLowerCase() ?? '';
      if (inputText.isEmpty) {
        _filteredSuggestions = [];
      } else {
        _filteredSuggestions = _allSuggestions
            .where((suggestion) => suggestion.toLowerCase().contains(inputText))
            .toList();
      }
    });
    _showOverlay2(); 
  }
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> uploadItem() async {
    try {
      print("fasfsda${token}");

      final response = await http.post(
        Uri.parse(
            'http://192.168.1.179:5000/shopping-list/add-a-shopping-list-mobile'),
        headers: {
          'Authorization': 'Bearer ${token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'item':
              '["amount: ${_newQtntyItemController.text}", "ingredient: ${_newItemController.text} "]',
        }),
      );

      if (response.statusCode == 200) {
        print("object");
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      print('Error fetching recipes: $e');
    }
    _newQtntyItemController.clear();
    _newItemController.clear();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => super.widget));
  }

  void openInputTypingField() {
    setState(() {
      openInput = true;
      openText = false;
    });
  }

  void closeTypingField() {
    setState(() {
      openInput = false;
      openText = true;
      if (_newItemController.text.isNotEmpty) {
        uploadItem();
      }
    });
  }

  Future<void> delete(_itemID, index) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.1.179:5000/shopping-list/delete-item-mobile'),
        headers: {
          'Authorization': 'Bearer ${token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'id': _itemID,
        }),
      );

      if (response.statusCode == 200) {
        print("deleted");
        setState(() {
          shopping_cart.removeAt(index);
          _controllersQTY.remove(index);
          _controllersITM.remove(index);
        });
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      print('Error fetching recipes: $e');
    }
  }

  Future<void> bought(_itemID, index) async {
    try {
      final response = await http.put(
        Uri.parse(
            'http://192.168.1.179:5000/storage/add-item-from-sList-mobile'),
        headers: {
          'Authorization': 'Bearer ${token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'id': _itemID,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          final item = shopping_cart.firstWhere((item) => item['id'] == _itemID,
              orElse: () => null);
          if (item != null) {
            item['checked'] = true;
          }
        });
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
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Container(
              child: Center(
                child: Column(
                  children: [
                    Container(
                        margin: const EdgeInsets.only(
                            left: 7, right: 7, top: 50, bottom: 10),
                        decoration: new BoxDecoration(
                          borderRadius: new BorderRadius.circular(16.0),
                          color: Color.fromARGB(255, 224, 152, 80),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: Text(
                                "SHOPPING CART",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 30),
                              ),
                            ),
                            SizedBox(
                              height: 500, // give height
                              child: shopping_cart.isEmpty
                                  ? Center(
                                      child: Text(
                                          "No items in your shopping cart"))
                                  : Container(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 20),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: shopping_cart.length + 1,
                                          itemBuilder: (context, index) {
                                            if (index == shopping_cart.length) {
                                              return ListTile(
                                                title: Row(
                                                  children: [
                                                    if (openText)
                                                      InkWell(
                                                        onTap: () {
                                                          openInputTypingField();
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(left: 20),
                                                          child: Text(
                                                              "click here to add a new item"),
                                                        ),
                                                      ),
                                                    if (openInput)
                                                      Row(
                                                        children: [
                                                          Container(
                                                              width: 60,
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    _newQtntyItemController,
                                                                decoration:
                                                                    const InputDecoration(
                                                                  border:
                                                                      UnderlineInputBorder(),
                                                                  labelText:
                                                                      'Qnty',
                                                                ),
                                                              )),
                                                        SingleChildScrollView (
                                                                   controller: _scrollController,
                                                                   
        scrollDirection: Axis.vertical,
                                                          child: Container(
                                                            width: 190,
                                                            child: CompositedTransformTarget(
                                                              link: _newLayerController,
                                                              child: GestureDetector(
                                                                onTap: () {
                                                                  _scrollController.animateTo(
                                                                    _scrollController.position.maxScrollExtent,
                                                                    duration: const Duration(milliseconds: 500),
                                                                    curve: Curves.easeInOut,
                                                                  );
                                                                },
                                                                child: TextFormField(
                                                                  controller: _newItemController,
                                                                  focusNode: _focusNode,
                                                                  decoration: const InputDecoration(
                                                                    border: UnderlineInputBorder(),
                                                                    labelText: 'Item',
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),

                                                          IconButton(
                                                            icon: Icon(
                                                                Icons.check),
                                                            onPressed: () {
                                                                      closeTypingField();

                                                            },
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left:
                                                                        25), // Adjust the padding value as needed
                                                          )
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                              );
                                            }
                                            final item = shopping_cart[index];
                                            var divided =
                                                item['item'].split(",");
                                            if (divided.length > 1 &&
                                                !item["checked"]) {
                                              var amount =
                                                  divided[0].trim().split(" ");
                                              amount = amount[1].split('"');
                                              var ingredient =
                                                  divided[1].trim().split(" ");
                                              if (amount.length > 1) {
                                                return ListTile(
                                                  title: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Row(
                                                      children: [
                                                        IconButton(
                                                          icon: Icon(Icons
                                                              .check_box_outline_blank),
                                                          onPressed: () {
                                                            bought(item['id'],
                                                                index);
                                                          },
                                                        ),
                                                        Container(
                                                          width: 250,
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                width: 60,
                                                                child:
                                                                    TextFormField(
                                                                  controller:
                                                                      _controllersQTY[
                                                                          item[
                                                                              'id']],
                                                                  focusNode:
                                                                      _focusNodesQTY[
                                                                          item[
                                                                              'id']],
                                                                  decoration:
                                                                      InputDecoration(
                                                                    border:
                                                                        UnderlineInputBorder(),
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                width: 190,
                                                                child:
                                                                    CompositedTransformTarget(
                                                                  link: _layerLinks[
                                                                      item[
                                                                          'id']]!, // Use the LayerLink associated with the item ID
                                                                  child:
                                                                      TextFormField(
                                                                    controller:
                                                                        _controllersITM[
                                                                            item['id']],
                                                                    focusNode:
                                                                        _focusNodesITM[
                                                                            item['id']],
                                                                    decoration:
                                                                        InputDecoration(
                                                                      border:
                                                                          UnderlineInputBorder(),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        IconButton(
                                                          icon: Icon(
                                                              Icons.delete),
                                                          onPressed: () {
                                                            delete(item['id'],
                                                                index);
                                                          },
                                                          padding: EdgeInsets.only(
                                                              left:
                                                                  25), // Adjust the padding value as needed
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                            return SizedBox.shrink();
                                          },
                                        ),
                                      ),
                                    ),
                            )
                          ],
                        )),
                    Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                              left: 7, right: 7, top: 50, bottom: 10),
                          decoration: new BoxDecoration(
                            borderRadius: new BorderRadius.circular(16.0),
                            color: Color.fromARGB(255, 224, 152, 80),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 12.0, left: 12, right: 12),
                                child: Text(
                                  "PREVIOUSLY BOUGHT",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 27),
                                ),
                              ),
                              Container(
                                height:
                                    400, // Set a fixed height for the ListView
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: shopping_cart.length,
                                  itemBuilder: (context, index) {
                                    final item = shopping_cart[index];
                                    if (item["checked"]) {
                                      var divided = item['item'].split(",");
                                      var amount = divided[0].trim().split(" ");
                                      amount = amount[1].split('"');
                                      var ingredient =
                                          divided[1].trim().split(" ");
                                      return ListTile(
                                        title: Row(
                                          children: [
                                            Text(
                                                "${amount[0]} ${ingredient[1]}",
                                                style: TextStyle(
                                                    decoration: TextDecoration
                                                        .lineThrough)),
                                            Spacer(),
                                            IconButton(
                                              icon: Icon(Icons.delete),
                                              onPressed: () {
                                                delete(item['id'], index);
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return SizedBox.shrink();
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
