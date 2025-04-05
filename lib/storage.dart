import 'package:flutter/material.dart';
import 'package:pantry_app/Components/STORAGE/add_item.dart';
import './Components/load_ingredients.dart';
import 'Components/suggestion_overlay.dart';
import './Components/Storage/API/storage_api.dart' as API;
import 'colors.dart';
import 'Components/HELPERS/get_categories.dart';
import 'Components/HELPERS/confirm_delete.dart';

class Storage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CreateStorageState();
}

class CreateStorageState extends State<Storage> {
  List<dynamic> _storage = [];
  Map<String, List<Map<String, dynamic>>> items =
      {}; //all items with key being a category and value other stuff ot the item

  Map<String, TextEditingController> _controllersQTY = {};
  Map<String, TextEditingController> _controllersITM = {};
  Map<String, FocusNode> _focusNodesQTY = {};
  Map<String, FocusNode> _focusNodesITM = {};
  List<String> suggestions = [];
  List<String> _filteredSuggestions = [];
  List<String> _allSuggestions = [];
  String selectedCategory = "";
  Map<String, LayerLink> _layerLinks = {};
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();
  Map<String, bool> openClose = {};
  final TextEditingController _ingredientController = TextEditingController();
  List<String> categories = [];
  final TextEditingController _itemController = TextEditingController();
  final FocusNode _addItemFocusNode = FocusNode();
  var openText = true;
  List<String> newCategories = [];

  final LayerLink _addItemLayerLink = LayerLink();

  SuggestionOverlay? _suggestionOverlay;

  @override
  void initState() {
    loadFood();
    super.initState();
    fetchCategories();

    fetchStorage().then((_) {
      loadFridge();
    });

    _suggestionOverlay = SuggestionOverlay(
      textController: _ingredientController,
      onSuggestionSelected: (String suggestion) {
        _ingredientController.text = suggestion;
      },
      context: context,
      layerLink: _addItemLayerLink,
    );
    _suggestionOverlay?.loadFood();

    _ingredientController.addListener(() {
      _suggestionOverlay?.updateSuggestions();
    });

    _addItemFocusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        if (_itemController.text.isNotEmpty) {
          setState(() {
            newCategories.add(_itemController.text);
          });

          _itemController.text = "";
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
    Overlay.of(context).insert(_overlayEntry!);
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

  Future<void> fetchStorage() async {
    _storage = await API.fetchStorage();
    //  _storage = await API.getStorageLocal() ?? [];
    print(_storage);
    setState(() {
      _storage = _storage;
    });
  }

  int findIndex(int itemID) {
    for (var i = 0; i < _storage.length; i++) {
      print(_storage[i]);
      if (_storage[i]["id"] == itemID) {
        return i;
      }
    }
    return -1;
  }

  Future<void> updateItem(int itemID, int index) async {
    var amount = _controllersQTY[itemID.toString()]?.text ?? '';
    var ingredient = _controllersITM[itemID.toString()]?.text ?? '';
    API.updateItem(itemID, amount, ingredient);

    var itemIndex = findIndex(itemID);

    setState(() {
      if (itemIndex != -1) {
        _storage[itemIndex]["amount"] = amount;
        _storage[itemIndex]["ingredient"] = ingredient;
        loadFridge();
      }
    });

    // API.updateStorageLocal(_storage);
  }

  

  Future<void> fetchCategories() async {
    List<String> fetchedCategories = await GetCategories.fetchCategories();
    setState(() {
      categories = fetchedCategories;
    });
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
      print(_storage);
      if (item != null && item['category'] != "") {
        print(item['category']);

        var category = item['category'].toLowerCase();
        if (items.containsKey(category)) {
          items[category]!.add(item);
        } else {
          items[category] = [item];
        }
        var controller = TextEditingController(text: item["ingredient"]);
        controller.addListener(
            () => _updateSuggestions(item['id'].toString(), item["id"]));
        _controllersITM[item["id"].toString()] = controller;
        _controllersQTY[item["id"].toString()] =
            TextEditingController(text: item["amount"]);

        var focusNode = FocusNode();
        focusNode.addListener(() {
          if (!focusNode.hasFocus) {
            //  updateItem((item["id"].toString()), item['id']);
          }
        });

        _focusNodesQTY[item["id"].toString()] = focusNode;
        _focusNodesITM[item["id"].toString()] = focusNode;
        _layerLinks[item["id"].toString()] = LayerLink();
        openClose[item["id"].toString()] = false;
      } else {
        if (items.containsKey("Default")) {
          items["Default"]!.add(item);
        } else {
          items["Default"] = [item];
        }
        _controllersITM["${item["id"]}"] =
            TextEditingController(text: item["ingredient"]);
        _controllersQTY["${item["id"]}"] =
            TextEditingController(text: item["amount"]);

        var focusNode = FocusNode();
        focusNode.addListener(() {
          if (!focusNode.hasFocus) {
            //     updateItem("${item["id"]}Default", item['id']);
          }
        });

        _focusNodesQTY["${item["id"]}"] = focusNode;
        _focusNodesITM["${item["id"]}"] = focusNode;
        _layerLinks["${item["id"]}"] = LayerLink();
        openClose["${item["id"]}"] = false;
      }
    }
  }

  Future<void> delete(int itemID, int index, key, String category) async {
    API.delete(itemID);

    var itemIndex = findIndex(itemID);

    setState(() {
      if (itemIndex != -1) {
        _storage.removeAt(itemIndex);

        loadFridge();
      }
    });

    // API.updateStorageLocal(_storage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: items.isEmpty
            ? Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Text("no items in your storage, you are broke..."),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.only(top: 50.0),
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: items.entries.map((entry) {
                            final category = entry.key;
                            final categoryItems = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(
                                  top: 20, left: 10, right: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: C.darkGrey,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15))),
                                child: Column(children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Text(
                                      category.toUpperCase(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,
                                        color: C.orange,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                          transform: Matrix4.translationValues(
                                              0.0, -40.0, 0.0),
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
                                                          openClose[item['id']
                                                                      .toString()] ==
                                                                  true
                                                              ? SizedBox(
                                                                  width: 100,
                                                                  child:
                                                                      TextFormField(
                                                                    controller:
                                                                        _controllersQTY[
                                                                            item['id'].toString()],
                                                                    /*     focusNode: _focusNodesQTY[
                                                                        item['id'].toString() ],*/
                                                                    decoration:
                                                                        InputDecoration(
                                                                      border:
                                                                          UnderlineInputBorder(),
                                                                    ),
                                                                  ),
                                                                )
                                                              : Container(),
                                                          openClose[item['id']
                                                                      .toString()] ==
                                                                  true
                                                              ? SizedBox(
                                                                  width: 190,
                                                                  child:
                                                                      CompositedTransformTarget(
                                                                    link: _layerLinks[
                                                                        item['id']
                                                                            .toString()]!,
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          _controllersITM[
                                                                              item['id'].toString()],
                                                                      focusNode:
                                                                          _focusNodesITM[
                                                                              item['id'].toString()],
                                                                      decoration:
                                                                          InputDecoration(
                                                                        border:
                                                                            UnderlineInputBorder(),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                              : Flexible(
                                                                  child: Text(
                                                                      "${item['amount']}: ${item['ingredient']}"),
                                                                ),
                                                        ],
                                                      ),
                                                    ),
                                                    openClose[item['id']
                                                                .toString()] ==
                                                            false
                                                        ? IconButton(
                                                            icon: Icon(
                                                                Icons.edit),
                                                            onPressed: () {
                                                              setState(() {
                                                                openClose[item[
                                                                            'id']
                                                                        .toString()] =
                                                                    true;
                                                              });
                                                            },
                                                          )
                                                        : Column(
                                                            children: [
                                                              IconButton(
                                                                icon: Icon(Icons
                                                                    .close),
                                                                onPressed: () {
                                                                  setState(() {
                                                                    openClose[item[
                                                                            'id']
                                                                        .toString()] = false;
                                                                  });
                                                                },
                                                              ),
                                                              ConfirmDeleteButton(
                                                                itemId: item[
                                                                    'id'].toString(),
                                                                index:
                                                                    index,
                                                                itemIdString: item[
                                                                        'id']
                                                                    .toString(), 
                                                                category:
                                                                    category, 
                                                                onDelete: (itemId,
                                                                    index,
                                                                    itemIdString,
                                                                    category) {
                                                                  delete(
                                                                      item[
                                                                          'id'],
                                                                      index,
                                                                      item['id']
                                                                          .toString(),
                                                                      category);
                                                                },
                                                              ),
                                                              IconButton(
                                                                icon: Icon(Icons
                                                                    .check),
                                                                onPressed: () {
                                                                  updateItem(
                                                                      item[
                                                                          'id'],
                                                                      index);
                                                                },
                                                              ),
                                                            ],
                                                          )
                                                  ],
                                                ),
                                                subtitle: openClose[item['id']
                                                            .toString()] ==
                                                        true
                                                    ? Row(
                                                        children: [],
                                                      )
                                                    : Row(
                                                        children: [],
                                                      ),
                                              );
                                            },
                                          )),
                                    ],
                                  )
                                ]),
                              ),
                            );
                          }).toList(),
                        )),
                  ],
                ),
              ),
        floatingActionButton: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddStorageItem()),
            );
          },
          child: Container(
              height: 75.0,
              width: 75.0,
              decoration: BoxDecoration(
                color: C.orange,
                shape: BoxShape.circle, // Make the container circular
              ),
              child: Center(
                child: Icon(
                  Icons.add,
                  size: 40,
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
