import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart'; // For rootBundle
import 'Components/ShoppingList/API/shopping_cart_api.dart' as API;
import './Components/SHOPPING_CART/shopping_list_tab.dart';
import 'Classes/list_item.dart';
import 'colors.dart';

class ShoppingCart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CreateShoppingCartState();
}

class CreateShoppingCartState extends State<ShoppingCart> {
  List<ListItem> shoppingCart = [];
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
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry(int itemId) {
    if (!_layerLinks.containsKey(itemId)) {
      print("LayerLink for itemId $itemId is missing");
      return OverlayEntry(builder: (context) => Text("data"));
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
    Overlay.of(context).insert(_overlayEntry!);
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
    var amount = _controllersQTY[index]?.text ?? '';
    var ingredient = _controllersITM[index]?.text ?? '';

    int position = shoppingCart.indexWhere((item) => item.id == id);

    API.updateItem(amount, ingredient, id);
    setState(() {
      shoppingCart[position].amount = amount;
      shoppingCart[position].ingredient = ingredient;
    });
    //API.updateStorageLocal(shoppingCart);
  }

  Future<void> getItems() async {
    shoppingCart = await API.getItems();

    setState(() {
      for (var item in shoppingCart) {
        print(item.id);
        var controller = TextEditingController(text: item.amount);
        _controllersQTY[item.id] = controller;

        var controller2 = TextEditingController(text: item.ingredient);
        controller2.addListener(() => _updateSuggestions(item.id));
        _controllersITM[item.id] = controller2;
      }

      _focusNodesQTY = Map.fromIterable(
        shoppingCart,
        key: (item) => item.id as int,
        value: (item) {
          var focusNode = FocusNode();
          focusNode.addListener(() {
            if (!focusNode.hasFocus) {
              updateItem(item.id, item.id);
            }
          });
          return focusNode;
        },
      );

      _focusNodesITM = Map.fromIterable(
        shoppingCart,
        key: (item) => item.id as int,
        value: (item) {
          var focusNode = FocusNode();

          focusNode.addListener(() {
            if (!focusNode.hasFocus) {
              updateItem(item.id, item.id);
            }
          });

          return focusNode;
        },
      );

      _layerLinks = {for (var item in shoppingCart) item.id: LayerLink()};
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
      String inputText = _newItemController.text.toLowerCase();
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
    print('Adding New Item');
    API.uploadItem(_newQtntyItemController.text, _newItemController.text);
    shoppingCart = await API.getItems();
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

  Future<void> delete(itemID, index) async {
    setState(() {
      shoppingCart.removeAt(index);
      _controllersQTY.remove(index);
      _controllersITM.remove(index);
    });
    API.delete(itemID);
  }

  Future<void> bought(itemID, index) async {
    API.bought(itemID);
    getItems();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(0),
              child: TabBar(
                tabs: [
                  Tab(text: "SHOPPING LIST"),
                  Tab(text: "PREV. BOUGHT"),
                ],
                indicatorColor: C.orange, 
                labelColor: C.orange, 
                unselectedLabelColor: Colors.grey,
              ),
            ),
          ),
          body: TabBarView(
            children: [
              ShoppingCartView(
                  shoppingCart: shoppingCart,
                  openText: openText,
                  openInput: openInput,
                  newQtntyItemController: _newQtntyItemController,
                  newItemController: _newItemController,
                  scrollController: _scrollController,
                  focusNode: _focusNode,
                  openInputTypingField: openInputTypingField,
                  closeTypingField: closeTypingField,
                  bought: bought,
                  delete: delete,
                  name: "SHOPPING CART",
                  checked: false,
                  controllersQTY: _controllersQTY,
                  controllersITM: _controllersITM,
                  focusNodesITM: _focusNodesITM,
                  focusNodesQTY: _focusNodesQTY,
                  layerLinks: _layerLinks,
                  newLayerController: _newLayerController),
              ShoppingCartView(
                  shoppingCart: shoppingCart,
                  openText: openText,
                  openInput: openInput,
                  newQtntyItemController: _newQtntyItemController,
                  newItemController: _newItemController,
                  scrollController: _scrollController,
                  focusNode: _focusNode,
                  openInputTypingField: openInputTypingField,
                  closeTypingField: closeTypingField,
                  bought: bought,
                  delete: delete,
                  name: "PREVIOUSLY BOUGHT",
                  checked: true,
                  controllersQTY: _controllersQTY,
                  controllersITM: _controllersITM,
                  focusNodesITM: _focusNodesITM,
                  focusNodesQTY: _focusNodesQTY,
                  layerLinks: _layerLinks,
                  newLayerController: _newLayerController),
            ],
          ),
        ));
  }
}
