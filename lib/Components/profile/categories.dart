import 'dart:async';
import 'package:flutter/material.dart';
// For rootBundle
import '../load_token.dart' as load_token;
import 'API/categories.dart' as API;
import '../../colors.dart';
import '../HELPERS/addButton.dart';
import '../HELPERS/customOverlay.dart';

class Categories extends StatefulWidget {
  @override
  _categoriesState createState() => _categoriesState();
}

class _categoriesState extends State<Categories> {
  String? token;
  List<dynamic> categories = [];
  OverlayEntry? _overlayEntry;
  TextEditingController _newCategoryController = TextEditingController();

  List<bool> _checkedValues = [];
  Map<int, TextEditingController> _categoriesControllers = {};

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final loadedToken = await load_token.loadToken();

    setState(() {
      token = loadedToken;
    });
    getCategory();
  }

  void getCategory() async {
    var result = await API.getCategories(token);
    setState(() {
      categories = result;
      _checkedValues = List<bool>.filled(categories.length, false);
    });

    for (var category in categories) {
      var controller = TextEditingController(text: category["id"].toString());
      setState(() {
        _categoriesControllers[category["id"]] = controller;
      });
    }

    print(categories);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

 

  void addCategory() async {
    await API.addCategory(_newCategoryController.text, token!);
    getCategory();
  }

  void editCategory(int index, var categoryId) async {
    if (_categoriesControllers[categoryId]!.text.isNotEmpty) {
      print(_categoriesControllers[categoryId]!.text);
      print(categoryId);

      await API.editCategory(
          _categoriesControllers[categoryId]!.text, categoryId, token!);

      _checkedValues[index] = !_checkedValues[index];

      getCategory();
    }
  }

  void deleteCategory(int index, var categoryId) async {
    if (_categoriesControllers[categoryId]!.text.isNotEmpty) {
      //     var result =  API.editCategory(_categoriesControllers[categoryId]!.text, categoryId, token!);

      _checkedValues[index] = !_checkedValues[index];

      getCategory();
    }
  }

 void _showAddCategoryOverlay() {
  CustomOverlay(
    context: context,
    controller: _newCategoryController,
    onSave: addCategory,  
    title: "New Category",  
  ).show();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'YOUR CATEGORIES',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: C.orange,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Container(
          margin: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              Flexible(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final categoryText =
                          category['category'] ?? 'No category';
                      return _checkedValues[index]
                          ? Container(
                              margin: const EdgeInsets.only(
                                  bottom: 20, left: 20, right: 20),
                              decoration: BoxDecoration(
                                  border: Border.all(color: C.orange),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                        Expanded(
                                        child:  ListTile(
                                          title: TextFormField(
                                        controller: _categoriesControllers[
                                            category['id']],
                                        decoration: InputDecoration(
                                          border: UnderlineInputBorder(),
                                        ),
                                      ))
                                      ),
                                     /* IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          setState(() {
                                            deleteCategory(
                                                index, category["id"]);
                                          });
                                        },
                                      ),*/
                                      IconButton(
                                        icon: Icon(Icons.close),
                                        onPressed: () {
                                          setState(() {
                                            _checkedValues[index] =
                                                !_checkedValues[index];
                                          });
                                        },
                                      ),
                                       IconButton(
                                        icon: Icon(Icons.check),
                                        onPressed: () {
                                          setState(() {
                                            editCategory(index, category["id"]);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                     
                                     
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              margin: const EdgeInsets.only(
                                  bottom: 20, left: 20, right: 20),
                              decoration: BoxDecoration(
                                  boxShadow: [],
                                  border: Border.all(color: C.orange),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ListTile(
                                          title: Text(categoryText.toString()),
                                        ),
                                      ),
                                      Spacer(),
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          setState(() {
                                            _checkedValues[index] =
                                                !_checkedValues[index];
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                    }),
              ),
            ],
          ),
        ),
      floatingActionButton: CustomFloatingButton(
  onTap: _showAddCategoryOverlay, // Pass function reference
  color: C.orange, // Optional, defaults to orange
),

);
  }
}
