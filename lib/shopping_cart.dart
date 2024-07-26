import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Components/load_token.dart' as load_token;
import 'dart:convert';

class ShoppingCart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CreateShoppingCartState();
}

class CreateShoppingCartState extends State<ShoppingCart> {
  List shopping_cart = [];

  TextEditingController _newItemController = TextEditingController();
  TextEditingController _newQtntyItemController = TextEditingController();
  Map<int, TextEditingController> _controllersQTY = {};
  Map<int, TextEditingController> _controllersITM = {};
  Map<int, FocusNode> _focusNodesQTY = {};
  Map<int, FocusNode> _focusNodesITM = {};

  var openInput = false;
  var openText = true;
  final FocusNode _focusNode = FocusNode();
  String? token;

  @override
  void initState() {
    super.initState();
    _loadToken().then((_) {
      getItems();
    });
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        closeTypingField();
      } else {
        openInputTypingField();
      }
    });
  }

  Future<void> updateItem(int index, String id) async {
    try {
      print('$index index');

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

      print(response.body);
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

              print(
                  'Initialized _controllersQTY[${item['id']}] with text: ${controller.text}');
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
              print(
                  'Initialized _controllersITM[${item['id']}] with text: ${controller.text}');
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
        });
        print(data["items"]);
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      print('Error fetching items: $e');
    }
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
      print("fasfsda${token}");
      print(_itemID);

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
      print("fasfsda${token}");
      print(_itemID);

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
        print("bought");
        print(shopping_cart);

        setState(() {
              shopping_cart.removeWhere((item) => item['id'] == _itemID);
          _controllersQTY.remove(index);
          _controllersITM.remove(index);
          _focusNodesQTY.remove(index);
          _focusNodesITM.remove(index);
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
      body: Center(
          child: Container(
        margin: const EdgeInsets.only(left: 7, right: 7, top: 50, bottom: 10),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
            ),
            Expanded(
              child: shopping_cart.isEmpty
                  ? Center(child: Text("No items in your shopping cart"))
                  : Container(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ListView.builder(
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
                                        child: Text(
                                            "click here to add a new item"),
                                      ),
                                    if (openInput)
                                      Row(
                                        children: [
                                          Container(
                                              width: 50,
                                              child: TextFormField(
                                                controller:
                                                    _newQtntyItemController,
                                                decoration:
                                                    const InputDecoration(
                                                  border:
                                                      UnderlineInputBorder(),
                                                  labelText: 'Enter Qnty here',
                                                ),
                                              )),
                                          Container(
                                              width: 100,
                                              child: TextFormField(
                                                controller: _newItemController,
                                                focusNode: _focusNode,
                                                decoration:
                                                    const InputDecoration(
                                                  border:
                                                      UnderlineInputBorder(),
                                                  labelText: 'Enter item here',
                                                ),
                                              )),
                                        ],
                                      ),
                                  ],
                                ),
                              );
                            }

                            final item = shopping_cart[index];
                            var divided = item['item'].split(",");
                            if (divided.length > 1 && !item["checked"]) {
                              var amount = divided[0].trim().split(" ");
                              amount = amount[1].split('"');
                              var ingredient = divided[1].trim().split(" ");
                              if (amount.length > 1) {
                                return ListTile(
                                  title: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                              Icons.check_box_outline_blank),
                                          onPressed: () {
                                            bought(item['id'], index);
                                          },
                                        ),
                                        Container(
                                          width: 250,
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 60,
                                                child: TextFormField(
                                                  controller:
                                                      _controllersQTY[item['id']],
                                                  focusNode:
                                                      _focusNodesQTY[item['id']],
                                                  decoration: InputDecoration(
                                                    border:
                                                        UnderlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 190,
                                                child: TextFormField(
                                                  controller:
                                                      _controllersITM[item['id']],
                                                  focusNode:
                                                      _focusNodesITM[item['id']],
                                                  decoration: InputDecoration(
                                                    border:
                                                        UnderlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            delete(item['id'], index);
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
            ),
          ],
        ),
      )),
    );
  }
}
