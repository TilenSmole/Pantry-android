import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Components/load_token.dart' as load_token;
import 'dart:convert';
import './Components/load_ingredients.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'Components/ShoppingList/API/shopping_cartAPI.dart' as API;
import 'package:shared_preferences/shared_preferences.dart';

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
  List<String> _filteredSuggestions = [];
  List<String> _allSuggestions = [];
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
    getItems();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _removeOverlay();
      } else {
        openInputTypingField();
        _showOverlay2();
      }
    });
    _layerLinks[-1] = LayerLink();
  }

  Future<void> setFood(String fileName, String key) async {
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

    LayerLink link = _newLayerController;
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
                        _newItemController.text = _filteredSuggestions[index];
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

  Future<void> updateItem(int index, int id) async {
    var amount = _controllersQTY[index]?.text ?? 'default';
    var ingredient = _controllersITM[index]?.text ?? 'default';

    int position = shopping_cart.indexWhere((item) => item['id'] == id);

    API.updateItem(amount, ingredient, id);
    setState(() {
      shopping_cart[position]["amount"] = amount;
      shopping_cart[position]["ingredient"] = ingredient;
    });
    API.updateStorageLocal(shopping_cart);
  }

  Future<void> getItems() async {
   // shopping_cart = await API.getItems();
    shopping_cart = await API.getStorageLocal();
    print("klicen");

    setState(() {
      _controllersQTY = Map.fromIterable(
        shopping_cart,
        key: (item) => item['id'] as int,
        value: (item) {
          var controller = TextEditingController(text: item["amount"]);

          return controller;
        },
      );

      _controllersITM = Map.fromIterable(
        shopping_cart,
        key: (item) => item['id'] as int,
        value: (item) {
          var controller = TextEditingController(text: item["ingredient"]);
          controller.addListener(() => _updateSuggestions(item['id']));
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
              updateItem(item['id'], item['id']);
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
              updateItem(item['id'], item['id']);
            }
          });

          return focusNode;
        },
      );

      _layerLinks = {
        for (var item in shopping_cart) item['id'] as int: LayerLink()
      };
    });

    //  print(data["items"]);
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idItemStr = prefs.getString('idItem');

    int idItem = idItemStr != null ? int.parse(idItemStr) : 0;

    //API.uploadItem(_newQtntyItemController.text, _newItemController.text);

    final Map<String, dynamic> item = {
      'id': idItem - 1,
      'amount': _newQtntyItemController.text,
      'ingredient': _newItemController.text,
      'checked': false,
      'userId': 1,
    };
    await prefs.setString('idItem', (idItem - 1).toString());
    setState(() {
      _controllersQTY[item['id']] = TextEditingController(text: item["amount"]);
      _controllersITM[item['id']] =
          TextEditingController(text: item["ingredient"]);
      var focusNode = FocusNode();
      focusNode.addListener(() {
        if (!focusNode.hasFocus) {
          updateItem(item['id'], item['id']);
        }
      });
      _focusNodesQTY[item['id']] = focusNode;
      _focusNodesITM[item['id']] = focusNode;

      _layerLinks[item["id"]] = LayerLink();
      shopping_cart.add(item);
    });
    API.updateStorageLocal(shopping_cart);
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
    //API.delete(_itemID);

    setState(() {
      shopping_cart.removeAt(index);
      _controllersQTY.remove(index);
      _controllersITM.remove(index);
    });

    API.updateStorageLocal(shopping_cart);
  }

  Future<void> bought(_itemID, index) async {
    //API.bought(_itemID);

setState(() {
  final item = shopping_cart.firstWhere(
    (item) => item['id'] == _itemID,
    orElse: () {
      final newItem = {'id': _itemID, 'checked': true};
      shopping_cart.add(newItem);
      return newItem;
    },
  );
  
  if (item != null) {
    item['checked'] = true;
  }
});
    API.updateStorageLocal(shopping_cart);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  SingleChildScrollView(
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
                                color: const Color.fromARGB(255, 220, 186, 135),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 30),
                                    child: Text(
                                      "SHOPPING CART",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 500, // give height
                                    child: Container(
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
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 20),
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
                                                          SingleChildScrollView(
                                                            controller:
                                                                _scrollController,
                                                            scrollDirection:
                                                                Axis.vertical,
                                                            child: Container(
                                                              width: 190,
                                                              child:
                                                                  CompositedTransformTarget(
                                                                link:
                                                                    _newLayerController,
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    _scrollController
                                                                        .animateTo(
                                                                      _scrollController
                                                                          .position
                                                                          .maxScrollExtent,
                                                                      duration: const Duration(
                                                                          milliseconds:
                                                                              500),
                                                                      curve: Curves
                                                                          .easeInOut,
                                                                    );
                                                                  },
                                                                  child:
                                                                      TextFormField(
                                                                    controller:
                                                                        _newItemController,
                                                                    focusNode:
                                                                        _focusNode,
                                                                    decoration:
                                                                        const InputDecoration(
                                                                      border:
                                                                          UnderlineInputBorder(),
                                                                      labelText:
                                                                          'Item',
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
                                            final item = shopping_cart[index]!;
                                            /* var divided =
                                                item['item'].split(",");*/
                                            if (item.length > 1 &&
                                                !item["checked"]) {
                                              /*var amount =
                                                  divided[0].trim().split(" ");
                                              amount = amount[1].split('"');
                                              var ingredient =
                                                  divided[1].trim().split(" ");*/
                                              if (item.length > 1) {
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
                                    left: 7, right: 7, top: 50, bottom: 40),
                                decoration: new BoxDecoration(
                                  borderRadius: new BorderRadius.circular(16.0),
                                  color:
                                      const Color.fromARGB(255, 220, 186, 135),
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
                                            /*9var divided = item['item'].split(",");
                                      var amount = divided[0].trim().split(" ");
                                      amount = amount[1].split('"');
                                      var ingredient =
                                          divided[1].trim().split(" ");*/
                                            return ListTile(
                                              title: Row(
                                                children: [
                                                  Text(
                                                      "${item["amount"]} ${item["ingredient"]}",
                                                      style: TextStyle(
                                                          decoration:
                                                              TextDecoration
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
