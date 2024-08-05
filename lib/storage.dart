import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:http/http.dart' as http;
import 'Components/load_token.dart' as load_token;
import 'dart:convert';
import './Components/load_ingredients.dart';

class Storage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CreateStorageState();
}

class CreateStorageState extends State<Storage> {
  List _storage = [];
  Map<String, List<Map<String, dynamic>>> items =
      {}; //all items with key being a category and value other stuff ot the item
  String? token;
  Map<String, TextEditingController> _controllersQTY = {};
  Map<String, TextEditingController> _controllersITM = {};
  Map<String, FocusNode> _focusNodesQTY = {};
  Map<String, FocusNode> _focusNodesITM = {};
  List<String> suggestions = [];
  List<String> _filteredSuggestions = [];
  List<String> _allSuggestions = [];
  List<String> categories = [];

  Map<String, LayerLink> _layerLinks = {};
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();
  Map<String, bool> openClose = {};

  //final LayerLink _AddItemLink = LayerLink();
  final FocusNode _addCategoryFocusNode = FocusNode();

  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  final FocusNode _addAmountFocusNode = FocusNode();
  final FocusNode _addIngredientFocusNode = FocusNode();

  final FocusNode _addItemFocusNode = FocusNode();
  final LayerLink _addItemLayerLink = LayerLink();

  @override
  void initState() {
    loadFood();
    super.initState();
    _loadToken().then((_) {
      fetchStorage().then((_) {
        loadFridge();
      });
    });

    _addCategoryFocusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        print("objectfasdddd");
        if (_categoryController.text.length > 0) {
          categories.add(_categoryController.text);
          _categoryController.text = "";
        }
      }
    });
  }

  Future<void> loadFood() async {
    IngredientLoader loader = IngredientLoader();
    await Future.delayed(Duration(seconds: 1));
    _allSuggestions = loader.allSuggestions;
  }

  void _showOverlay(String mapId, int itemId) {
    print("Showing overlay");
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }
    _overlayEntry = _createOverlayEntry(mapId, itemId);
    Overlay.of(context)?.insert(_overlayEntry!);
  }

  void _showAddItemOverlay() {
    print("Showing overlay");
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }
    _overlayEntry = __AddItemOverlayEntry();
    Overlay.of(context)?.insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry(String mapId, int itemId) {
    if (!_layerLinks.containsKey(mapId)) {
      print("LayerLink for itemId $itemId is missing");
      return OverlayEntry(
          builder: (context) => Text(
              "data") // SizedBox.shrink(), // Empty widget if link is missing
          );
    }
    print("creating overlay");

    LayerLink link = _layerLinks[mapId]!;
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
                        _controllersITM[mapId]?.text =
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

  void _updateSuggestions(String mapId, int itemId) {
    print(mapId);
    print("Updating suggestions");
    setState(() {
      String inputText = _controllersITM[mapId]?.text.toLowerCase() ?? '';
      if (inputText.isEmpty) {
        _filteredSuggestions = [];
      } else {
        _filteredSuggestions = _allSuggestions
            .where((suggestion) => suggestion.toLowerCase().contains(inputText))
            .toList();
      }
    });
    _showOverlay(mapId, itemId);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _loadToken() async {
    final loadedToken = await load_token.loadToken();
    setState(() {
      token = loadedToken;
    });
  }

  Future<void> fetchStorage() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.179:5000/storage'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _storage = data["storage"];
        });
      } else {
        print(Exception('Failed to load storage data'));
      }
    } catch (e) {
      print('Error fetching storage data: $e');
    }
  }

  Future<void> updateItem(String index, String id) async {
    try {
      // Extract values as strings
      var amount = _controllersQTY[index]?.text ?? 'default';
      var ingredient = _controllersITM[index]?.text ?? 'default';
      print("fadsasfasf");

      final response = await http.put(
        Uri.parse('http://192.168.1.179:5000/storage/update-storage-mobile'),
        headers: {
          'Authorization': 'Bearer ${token}',
          'Content-Type': 'application/json'
        },
        body:
            jsonEncode({'amount': amount, 'ingredient': ingredient, 'id': id}),
      );

      if (response.statusCode == 200) {
            final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _storage = data["storage"];
        });
                      loadFridge();
        _controllersQTY[index]?.text = amount;
        _controllersITM[index]?.text = ingredient;
      } else {
        throw Exception('Failed to update item');
      }
    } catch (e) {
      print('Error updating item: $e');
    }
  }

  Future<void> addANewItem() async {
    try {
      var amount = _amountController.text ?? 'default';
      var ingredient = _ingredientController.text ?? 'default';

      final response = await http.post(
        Uri.parse('http://192.168.1.179:5000/storage/add-storage-item-mobile'),
        headers: {
          'Authorization': 'Bearer ${token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'amount': amount,
          'ingredient': ingredient,
          "category": categories
        }),
      );

      if (response.statusCode == 200) {
        print("Update successful");
        final Map<String, dynamic> data = jsonDecode(response.body);
        print(data["storage"]);
        setState(() {
          _storage.add(data["storage"]);
          categories = [];
          _ingredientController.text = "";
          _amountController.text = "";
          _categoryController.text = "";
          _removeOverlay();
        });
                  loadFridge();

      } else {
        throw Exception('Failed to update item');
      }
    } catch (e) {
      print('Error updating item: $e');
    }
  }

  Future<void> loadFridge() async {
 _controllersQTY = {};
_controllersITM = {};
_focusNodesQTY = {};
 _focusNodesITM = {};
 _layerLinks = {};
 openClose = {};
 items = {};
    for (var item in _storage) {
      if (item != null && item['category']!.isNotEmpty) {
        for (var category in item['category']) {
          if (items.containsKey(category)) {
            items[category]!.add(item);
          } else {
            items[category] = [item];
          }
          var controller = TextEditingController(text: item["ingredient"]);
          controller.addListener(() =>
              _updateSuggestions(item['id'].toString() + category, item["id"]));
          _controllersITM[item["id"].toString() + category] = controller;
          _controllersQTY[item["id"].toString() + category] =
              TextEditingController(text: item["amount"]);

          var focusNode = FocusNode();
          focusNode.addListener(() {
            if (!focusNode.hasFocus) {
              updateItem(
                  (item["id"].toString() + category), item['id'].toString());
            }
          });

          _focusNodesQTY[item["id"].toString() + category] = focusNode;
          _focusNodesITM[item["id"].toString() + category] = focusNode;
          _layerLinks[item["id"].toString() + category] = LayerLink();
                openClose[item["id"].toString() + category] = false;

        }
      } else {
        if (items.containsKey("default")) {
          items["default"]!.add(item);
        } else {
          items["default"] = [item];
        }
        _controllersITM[item["id"].toString() + "default"] =
            TextEditingController(text: item["ingredient"]);
        _controllersQTY[item["id"].toString() + "default"] =
            TextEditingController(text: item["amount"]);

        var focusNode = FocusNode();
        focusNode.addListener(() {
          if (!focusNode.hasFocus) {
            updateItem(
                item["id"].toString() + "default", item['id'].toString());
          }
        });

        _focusNodesQTY[item["id"].toString() + "default"] = focusNode;
        _focusNodesITM[item["id"].toString() + "default"] = focusNode;
        _layerLinks[item["id"].toString() + "default"] = LayerLink();
              openClose[item["id"].toString() + "default"] = false;

      }

    }

  }

  Future<void> delete(int itemID, String index, item) async {
    try {
      print(token);
      print(itemID);

      final response = await http.delete(
        Uri.parse(
            'http://192.168.1.179:5000/storage/delete-storage-item-mobile/'),
        headers: {
          'Authorization': 'Bearer ${token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'id': itemID,
        }),
      );

      if (response.statusCode == 200) {
        print("deleted");
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _storage = data["storage"];
        });
                      loadFridge();

      } else {
        print('Failed to delete from storage');
      }
    } catch (e) {
      print('Error fetching recipes: $e');
    }
  }

  OverlayEntry __AddItemOverlayEntry() {
    print("object");

    return OverlayEntry(
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return Positioned(
          left: 30, // Center horizontally
          top: (100), // Center vertically
          height: 500.0,
          width: 300,
          child: Material(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 400, maxWidth: 400),
              child: Container(
                padding: EdgeInsets.all(16.0),
                color: const Color.fromARGB(255, 205, 205, 205),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Row(
                        children: [
                          Text("ADD A NEW STORAGE ITEM"),
                          Spacer(),
                          Expanded(
                            child: IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _removeOverlay();
                                });
                                ;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextFormField(
                      controller: _amountController,
                      focusNode: _addAmountFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Enter the amount',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    TextFormField(
                      controller: _ingredientController,
                      focusNode: _addIngredientFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Enter the ingredient',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    TextFormField(
                      controller: _categoryController,
                      focusNode: _addCategoryFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Enter the category',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    Text("Categories:"),
                    Container(
                      height: 150,
                      child: ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return Text(categories[index]);
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.done),
                      onPressed: () {
                        setState(() {
                          addANewItem();
                        });
                        ;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('YOUR STORAGE'),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: items.isEmpty
                      ? Text('No items in storage')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: items.entries.map((entry) {
                            final category = entry.key;
                            final categoryItems = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 10, right: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 220, 186, 135),
                                    border: Border.all(),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        category.toUpperCase(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 28.0),
                                      child: Container(
                                          constraints: BoxConstraints(),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(), // Disable scrolling inside a scrollable parent
                                            itemCount: categoryItems.length,
                                            itemBuilder: (context, index) {
                                              final item = categoryItems[index];
                                              return ListTile(
                                                title: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Row(
                                                        children: [
                                                          openClose[item['id'].toString()+  category] ==
                                                                  true
                                                              ? Container(
                                                                  width: 80,
                                                                  child:
                                                                      TextFormField(
                                                                    controller: _controllersQTY[
                                                                        item['id'].toString() +
                                                                            category],
                                                               /*     focusNode: _focusNodesQTY[
                                                                        item['id'].toString() +
                                                                            category],*/
                                                                    decoration:
                                                                        InputDecoration(
                                                                      border:
                                                                          UnderlineInputBorder(),
                                                                    ),
                                                                  ),
                                                                )
                                                              : Container(),
                                                          openClose[item['id'].toString() +  category] ==
                                                                  true
                                                              ? Container(
                                                                  width: 170,
                                                                  child:
                                                                      CompositedTransformTarget(
                                                                    link: _layerLinks[
                                                                        item['id'].toString() +
                                                                            category]!, 
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          _controllersITM[item['id'].toString() +
                                                                              category],
                                                                      focusNode:
                                                                          _focusNodesITM[item['id'].toString() +
                                                                              category],
                                                                      decoration:
                                                                          InputDecoration(
                                                                        border:
                                                                            UnderlineInputBorder(),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                              : Text(item[
                                                                      "amount"] +
                                                                  " x " +
                                                                  item[
                                                                      "ingredient"]),
                                                        ],
                                                      ),
                                                    ),
                                                    openClose[item['id'].toString() +  category] ==
                                                            false
                                                        ? IconButton(
                                                            icon: Icon(
                                                                Icons.edit),
                                                            onPressed: () {
                                                              setState(() {
                                                                openClose[item['id'].toString() +
                                                                              category] =
                                                                    true;
                                                              });
                                                            },
                                                          )
                                                        : IconButton(
                                                            icon: Icon(
                                                                Icons.close),
                                                            onPressed: () {
                                                              setState(() {
                                                                openClose[item['id'].toString() +
                                                                              category] =
                                                                    false;
                                                              });
                                                              ;
                                                            },
                                                          ),
                                                  ],
                                                ),
                                                subtitle: openClose[
                                                            item['id'].toString() +
                                                                              category] ==
                                                        true
                                                    ? Row(
                                                        children: [
                                                          IconButton(
                                                            icon: Icon(
                                                                Icons.delete),
                                                            onPressed: () {
                                                              delete(
                                                                  item['id'],
                                                                  item['id']
                                                                          .toString() +
                                                                      category,
                                                                  item);
                                                            },
                                                          ),
                                                          SizedBox(width: 8),
                                                          IconButton(
                                                            icon: Icon(
                                                                Icons.tune),
                                                            onPressed: () {
                                                              setState(() {});
                                                            },
                                                          ),
                                                        ],
                                                      )
                                                    : Row(
                                                        children: [],
                                                      ),
                                              );
                                            },
                                          )),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        )),
            ],
          ),
        ),
        floatingActionButton: GestureDetector(
          onTap: () {
            _showAddItemOverlay();
          },
          child: Container(
              height: 75.0,
              width: 75.0,
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle, // Make the container circular
              ),
              child: Center(
                child: Icon(
                  Icons.add,
                  size: 40,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              )),
        ));
  }
}

/* ListView.builder(
                itemCount: _storage.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_storage[index].toString()),
                  );
                },
              ),*/
