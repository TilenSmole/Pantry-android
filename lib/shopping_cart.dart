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
        });
        print(data["items"]);
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      print('Error fetching recipes: $e');
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
    _newQtntyItemController.text = "";
    _newItemController.text = "";
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => super.widget));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(30),
            child: Text("SHOPPING CART"),
          ),
        for (var item in shopping_cart)
            Text(
                "Amount: ${item["item"]}, Ingredient: ${item['id']}"),
          SizedBox(height: 8),
          if (openText)
            InkWell(
              onTap: () {
                openInputTypingField();
              },
              child: Text("click here to add a new item"),
            ),
          if (openInput)
            TextFormField(
              controller: _newItemController,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Enter item here',
              ),
            ),
          if (openInput)
            TextFormField(
              controller: _newQtntyItemController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Enter Qnty here',
              ),
            ),
        ],
      )),
    );
  }
}
