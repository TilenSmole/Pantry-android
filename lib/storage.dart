import 'package:flutter/material.dart';
import './Components/load_ingredients.dart';
import 'Components/SuggestionOverlay.dart';
import './Components/Storage/API/StorageAPI.dart' as API;
import 'package:shared_preferences/shared_preferences.dart';

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

  Map<String, FocusNode> _focusNodesCTGY = {};
  Map<String, TextEditingController> _controllersCTGY = {};

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

  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  final FocusNode _addAmountFocusNode = FocusNode();
  final FocusNode _addIngredientFocusNode = FocusNode();

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

    _addCategoryFocusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        if (_categoryController.text.isNotEmpty) {
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
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _showAddItemOverlay() {
    print("Showing overlay");
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }
    _overlayEntry = __AddItemOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _showChangeCategoyOverlay(List<dynamic> categories, String id) {
    print("Showing overlay");
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }
    _overlayEntry = _ChangeCategoryOverlay(categories, id);
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

  Future<void> updateItem(String index, int itemID) async {
    var amount = _controllersQTY[index]?.text ?? 'default';
    var ingredient = _controllersITM[index]?.text ?? 'default';
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

  Future<void> updateCategory(List<dynamic> category, String itemID) async {
    API.updateCategory(category, itemID);

    var itemIndex = findIndex(int.parse(itemID));

    setState(() {
      if (itemIndex != -1) {
        _storage[itemIndex]["category"] = category;
        loadFridge();
      }
    });

   // API.updateStorageLocal(_storage);
  }

  Future<void> addANewItem() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idItemStr = prefs.getString('idItem');
    int idItem = idItemStr != null ? int.parse(idItemStr) : 0;

    var amount = _amountController.text ?? 'default';
    var ingredient = _ingredientController.text ?? 'default';
     API.addANewItem(amount, ingredient, categories);

    final Map<String, dynamic> item = {
      'id': idItem - 1,
      'amount': amount,
      'ingredient': ingredient,
      'category': categories,
      'userId': 1,
    };
    await prefs.setString('idItem', (idItem - 1).toString());

    setState(() {
      _storage.add(item);
      categories = [];
      _removeOverlay();
      loadFridge();
    });

   // API.updateStorageLocal(_storage);
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
              updateItem((item["id"].toString() + category), item['id']);
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
        _controllersITM["${item["id"]}default"] =
            TextEditingController(text: item["ingredient"]);
        _controllersQTY["${item["id"]}default"] =
            TextEditingController(text: item["amount"]);

        var focusNode = FocusNode();
        focusNode.addListener(() {
          if (!focusNode.hasFocus) {
            updateItem("${item["id"]}default", item['id']);
          }
        });

        _focusNodesQTY["${item["id"]}default"] = focusNode;
        _focusNodesITM["${item["id"]}default"] = focusNode;
        _layerLinks["${item["id"]}default"] = LayerLink();
        openClose["${item["id"]}default"] = false;
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

  OverlayEntry __AddItemOverlayEntry() {
    print("object");

    return OverlayEntry(
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return Positioned(
          left: 30,
          top: 100,
          height: 500.0,
          width: 300,
          child: Container(
            clipBehavior: Clip.hardEdge,
            //    color: const Color.fromARGB(    255, 220, 186, 135),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromARGB(255, 208, 193, 171), // Border color
                width: 2.0, // Border width
              ),
              borderRadius: BorderRadius.circular(25.0), // Rounded corners
            ),
            child: Material(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 400, maxWidth: 400),
                child: Container(
                  color: Color.fromARGB(255, 208, 193, 171),
                  padding: EdgeInsets.all(16.0),
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
                      CompositedTransformTarget(
                        link: _addItemLayerLink,
                        child: TextFormField(
                          controller: _ingredientController,
                          focusNode: _addIngredientFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Enter the ingredient',
                            border: UnderlineInputBorder(),
                          ),
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
                      SizedBox(
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
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  OverlayEntry _ChangeCategoryOverlay(List<dynamic> categories, String id) {
    print("_ChangeCategoryOverlay");
    print(categories);
    newCategories = List.from(categories);
    for (var category in categories) {
      var controller = TextEditingController(text: category.toString());
      _controllersCTGY[id + category.toString()] = controller;
      var focusNode = FocusNode();
      focusNode.addListener(() {
        if (!focusNode.hasFocus) {
          print("jej");
          var newItem = _controllersCTGY[id + category.toString()]?.text;

          for (var i = 0; i < newCategories.length; i++) {
            if ((id.toString() + newCategories[i]) ==
                (id.toString() + category.toString())) {
              newCategories[i] =
                  _controllersCTGY[id + category.toString()] != null
                      ? _controllersCTGY[id + category.toString()]!.text
                      : "sth";
              // updateCategory(newCategories, id.toString());
            }
          }

          // newCategories[id + category.toString()] =  _controllersCTGY[id + category.toString()].text();
          // updateCategory(    newCategories, id.toString());
        }
      });
      _focusNodesCTGY[id + category.toString()] = focusNode;
    }

    return OverlayEntry(
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return Positioned(
          left: 30,
          top: 100,
          height: 500.0,
          width: 300,
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromARGB(255, 208, 193, 171), // Border color
                width: 2.0, // Border width
              ),
              borderRadius: BorderRadius.circular(25.0), // Rounded corners
            ),
            child: Material(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 400, maxWidth: 400),
                child: Container(
                  color: Color.fromARGB(255, 208, 193, 171),
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Row(
                          children: [
                            Text("EDIT ITEM'S CATEGORY"),
                            Spacer(),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _removeOverlay();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      // Use Expanded to allow ListView to take available space
                      Expanded(
                        child: ListView.builder(
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            var category = categories[index];

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _controllersCTGY[
                                          id + category.toString()],
                                      focusNode: _focusNodesCTGY[
                                          id + category.toString()],
                                      decoration: const InputDecoration(
                                        border: UnderlineInputBorder(),
                                        labelText: 'Category',
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      List<String> temp = [];
                                      for (var i = 0;
                                          i < newCategories.length;
                                          i++) {
                                        if ((id.toString() +
                                                newCategories[i]) ==
                                            (id.toString() +
                                                category.toString())) {
                                          continue;
                                        } else {
                                          temp.add(newCategories[i]);
                                        }
                                      }
                                      newCategories = temp;

                                      updateCategory(
                                          newCategories, id.toString());
                                      _removeOverlay();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                          child: TextFormField(
                        focusNode: _addItemFocusNode,
                        controller: _itemController,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'New Category',
                        ),
                      )),

                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: IconButton(
                          icon: Icon(Icons.done),
                          onPressed: () {
                            setState(() {
                              updateCategory(newCategories, id.toString());
                              _removeOverlay();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void openInputTypingField() {
    setState(() {
      openText = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('YOUR STORAGE'),
        ),
        body: items.isEmpty
            ? Center(
                child: SingleChildScrollView(
                  child: Text("no items in your storage, you are broke..."),
                ),
              )
            : SingleChildScrollView(
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
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
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
                                            padding: const EdgeInsets.only(
                                                bottom: 28.0),
                                            child: Container(
                                                constraints: BoxConstraints(),
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      NeverScrollableScrollPhysics(), // Disable scrolling inside a scrollable parent
                                                  itemCount:
                                                      categoryItems.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final item =
                                                        categoryItems[index];
                                                    return ListTile(
                                                      title: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Row(
                                                              children: [
                                                                openClose[item['id'].toString() +
                                                                            category] ==
                                                                        true
                                                                    ? SizedBox(
                                                                        width:
                                                                            80,
                                                                        child:
                                                                            TextFormField(
                                                                          controller:
                                                                              _controllersQTY[item['id'].toString() + category],
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
                                                                openClose[item['id'].toString() +
                                                                            category] ==
                                                                        true
                                                                    ? SizedBox(
                                                                        width:
                                                                            170,
                                                                        child:
                                                                            CompositedTransformTarget(
                                                                          link: _layerLinks[item['id'].toString() +
                                                                              category]!,
                                                                          child:
                                                                              TextFormField(
                                                                            controller:
                                                                                _controllersITM[item['id'].toString() + category],
                                                                            focusNode:
                                                                                _focusNodesITM[item['id'].toString() + category],
                                                                            decoration:
                                                                                InputDecoration(
                                                                              border: UnderlineInputBorder(),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : Flexible(
                                                                        child: Text(item["amount"] +
                                                                            " x " +
                                                                            item["ingredient"]),
                                                                      ),
                                                              ],
                                                            ),
                                                          ),
                                                          openClose[item['id']
                                                                          .toString() +
                                                                      category] ==
                                                                  false
                                                              ? IconButton(
                                                                  icon: Icon(
                                                                      Icons
                                                                          .edit),
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      openClose[item['id'].toString() +
                                                                              category] =
                                                                          true;
                                                                    });
                                                                  },
                                                                )
                                                              : IconButton(
                                                                  icon: Icon(Icons
                                                                      .close),
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      openClose[item['id'].toString() +
                                                                              category] =
                                                                          false;
                                                                    });
                                                                  },
                                                                ),
                                                        ],
                                                      ),
                                                      subtitle: openClose[item[
                                                                          'id']
                                                                      .toString() +
                                                                  category] ==
                                                              true
                                                          ? Row(
                                                              children: [
                                                                IconButton(
                                                                  icon: Icon(Icons
                                                                      .delete),
                                                                  onPressed:
                                                                      () {
                                                                    delete(
                                                                        item[
                                                                            'id'],
                                                                        index,
                                                                        item['id'].toString() +
                                                                            category,
                                                                        category);
                                                                  },
                                                                ),
                                                                SizedBox(
                                                                    width: 8),
                                                                IconButton(
                                                                  icon: Icon(
                                                                      Icons
                                                                          .tune),
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      _showChangeCategoyOverlay(
                                                                          item[
                                                                              'category'],
                                                                          item["id"]
                                                                              .toString());
                                                                    });
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
