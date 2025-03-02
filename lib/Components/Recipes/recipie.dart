import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:flutter/material.dart';
import 'API/recipeAPI.dart' as API;
import '../load_token.dart' as load_token;

import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


class Recepie extends StatefulWidget {
  Map<String, dynamic> recipe = {
    'name': 'Unknown Recipe',
    'ingredients': [], // Default to an empty list
    'amounts': [], // Default to an empty list
    'instructions': 'No instructions available',
    'cook_time': '0', // Default cooking time
    'prep_time': '0', // Default preparation time
    'imageUrl': '', // Default to an empty string or placeholder image URL
  };
  Recepie({Key? key, required this.recipe}) : super(key: key);
  @override
  State<StatefulWidget> createState() => RecepieState(recipe);
}

class RecepieState extends State<Recepie> {
  Map<String, dynamic> recipe;
  RecepieState(this.recipe);
  String? token;
  bool addedToList = false;
  OverlayEntry? _overlayEntry;

  final FocusNode _addNotefocusNode = FocusNode();
  final LayerLink _addNotelayerLink = LayerLink();
  final TextEditingController _addNoteController = TextEditingController();
  bool openAddNewNote = false;
  bool editNote = false;

  Map<int, TextEditingController> _notesController = {};
  Map<int, FocusNode> _notesFocusNode = {};

  List<dynamic>? notes = [];
  List<dynamic>? shoppingList = [];

  bool cook = false;

  //add selected items
  List<bool> _checkedValues = [];
  Map<int, String> _selectedAmounts = {};
  Map<int, String> _selectedIngredients = {};
  Map<int, TextEditingController> _amountsController = {};
  Map<int, FocusNode> _amountsFocusNode = {};
  bool canEditSelect = false;

  //freeze
  TextEditingController _freezePortionsCategory = TextEditingController();
  FocusNode _freezePortionsCategoryfocusNode = FocusNode();

  List<dynamic>? freezerCategories = [];
  final TextEditingController _freezePortions = TextEditingController();

  //edit main
  bool edit = false;
  TextEditingController _prepTimeController = TextEditingController();
  FocusNode _prepTimefocusNode = FocusNode();
  TextEditingController _cookTimeController = TextEditingController();
  FocusNode _cookTimefocusNode = FocusNode();
  TextEditingController _instructionsController = TextEditingController();

  Map<int, TextEditingController> _controllersQTY = {};
  Map<int, TextEditingController> _controllersITM = {};
  Map<String, FocusNode> _focusNodesQTY = {};
  Map<String, FocusNode> _focusNodesITM = {};

  Future<void> _loadToken() async {
    final loadedToken = await load_token.loadToken();

    setState(() {
      token = loadedToken;
    });
    notes = await API.getNotes(recipe["id"], token);

    if (notes != null) {
      for (var note in notes!) {
        var controller = TextEditingController(text: note["note"]);
        setState(() {
          _notesController[note["id"]] = controller;
        });
        var focusNode = FocusNode();
        focusNode.addListener(() {
          if (!focusNode.hasFocus) {
            API.editNote(_notesController[note["id"]]!.text, recipe["id"],
                note['id'], token!);
          }
        });
        setState(() {
          _notesFocusNode[note["id"]] = focusNode;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _loadToken().then((_) {
      _prepTimeController.text = recipe["prep_time"];
      _cookTimeController.text = recipe["cook_time"];
      _cookTimefocusNode.addListener(() {
        if (!_cookTimefocusNode.hasFocus) {
          updateCookTime();
                }
      });
      _prepTimefocusNode.addListener(() {
        if (!_prepTimefocusNode.hasFocus) {
          if (_prepTimeController.text.isNotEmpty) {
            updatePrepTime();
          }
        }
      });
      _instructionsController.text = recipe["instructions"];
      for (var i = 0; i < recipe["ingredients"].length; i++) {
        var controller = TextEditingController(text: recipe["ingredients"][i]);
        controller.addListener(() => _updateIngredient(i));
        _controllersITM[i] = controller;
        var controller2 = TextEditingController(text: recipe["amounts"][i]);
        controller2.addListener(() => _updateIngredient(i));

        _controllersQTY[i] = controller2;

      }
    });

    _checkedValues = List<bool>.filled(recipe["ingredients"].length, false);

    var i = 0;
    for (var amount in recipe["amounts"]) {
      var controller = TextEditingController(text: amount);
      setState(() {
        _amountsController[i++] = controller;
      });
    }
    _freezePortionsCategory.text = "freezer";
    _freezePortionsCategoryfocusNode.addListener(() {
      if (!_freezePortionsCategoryfocusNode.hasFocus) {
        setState(() {
          freezerCategories!.add(_freezePortionsCategory.text);
          _freezePortionsCategory.text = "";
        });
        _freezeOverlay();
            }
    });
  }

  void _updateIngredient(int index) {
      recipe["ingredients"][index] =  _controllersITM[index]!.text;
      recipe["amounts"][index] =  _controllersQTY[index]!.text;
  }

Future<void> createAndSharePdf() async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Text(
              recipe["name"].toString(),
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
               "Preparation time: ${recipe["prep_time"]?.toString() ?? "Unknown"} min",
              style: pw.TextStyle(
                fontSize: 16,
              ),
            ),
             pw.Text(
               "Cooking time: ${recipe["cook_time"]?.toString() ?? "Unknown"} min",
              style: pw.TextStyle(
                fontSize: 16,
              ),
            ),  
             pw.Text(
                "Total time: ${recipe["total_time"]?.toString() ?? "Unknown"} min",
              style: pw.TextStyle(
                fontSize: 16,
              ),
            ),
            pw.Container(
              child:  pw.Column(
                children: [
                  for(var i = 0; i < recipe["ingredients"].length; i++ )
                    pw.Text(recipe["amounts"][i] + " " +recipe["ingredients"][i]),
                ],
              ),
            ),
              pw.Text(
                 recipe["instructions"],
              style: pw.TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        );
      },
    ),
  );

  // Save and share the PDF file
  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename: '${recipe["name"].toString()}.pdf',
  );
}



  void updateInstructions() async {
    var result = await API.editInstructions(
      recipe["id"],
      _instructionsController.text,
      token!,
    );
    if (result == 0) {
      setState(() {
        recipe["instructions"] = _instructionsController.text;
        edit = false;
      });
    }
  }

  void updateIngredients() async {
    var result = await API.editIngredients(
      recipe["id"],
      recipe["ingredients"],
      recipe["amounts"],
      token!,
    );
    if (result == 0) {
      setState(() {
        recipe["instructions"] = _instructionsController.text;
        edit = false;
      });
    }
  }

  void updatePrepTime() async {
    var result = await API.edit_prep_time(
      recipe["id"],
      int.parse(_prepTimeController.text),
      token!,
    );
    if (result == 0) {
      setState(() {
        recipe["prep_time"] = _prepTimeController.text;
        edit = false;
      });
    }
  }

  void updateCookTime() async {
    var result = await API.edit_cook_time(
        recipe["id"], int.parse(_cookTimeController.text), token!);
    if (result == 0) {
      setState(() {
        recipe["cook_time"] = _cookTimeController.text;
        edit = false;
      });
    }
  }

  void _showAddNoteOverlay() {
    print("_showAddNoteOverlay");
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }
    _overlayEntry = _createAddNoteOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _changeOverlay(bool state) {
    openAddNewNote = state;
    _removeOverlay();
    _showAddNoteOverlay();
  }

  OverlayEntry _createAddNoteOverlayEntry() {

    return OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width / 1.5,
        top: MediaQuery.of(context).size.height / 3.5,
        left: MediaQuery.of(context).size.width / 6,
        child: Container(
          child: Material(
            elevation: 4.0,
            color: Colors
                .transparent, // Make Material's color transparent so that the Container's background color is visible
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white, // Background color of the Container
                borderRadius: BorderRadius.circular(16.0), // Rounded corners
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 20.0, left: 20, right: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text("NOTES"),
                          Spacer(),
                          !openAddNewNote
                              ? Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(!editNote
                                          ? Icons.edit
                                          : Icons.edit_note),
                                      onPressed: () {
                                        setState(() {
                                          editNote = !editNote;
                                          _changeOverlay(false);
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () {
                                        setState(() {
                                          _changeOverlay(true);
                                        });
                                      },
                                    )
                                  ],
                                )
                              : Container(),
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
                      if (!openAddNewNote && notes != null) ...[
                        if (editNote)
                          ListView.builder(
                              shrinkWrap: true,
                              physics:
                                  NeverScrollableScrollPhysics(), // Disable scrolling inside a scrollable parent
                              itemCount: notes!.length,
                              itemBuilder: (context, index) {
                                final note = notes![index];
                                return Column(
                                  children: [
                                    SizedBox(
                                      height: 200,
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: TextFormField(
                                          controller:
                                              _notesController[note['id']],
                                          focusNode:
                                              _notesFocusNode[note['id']],
                                          decoration: InputDecoration(
                                            border: UnderlineInputBorder(),
                                          ),
                                          maxLines:
                                              null, // Allows the TextFormField to expand vertically
                                          keyboardType: TextInputType.multiline,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () async {
                                        notes = await API.deleteNote(
                                            note["id"], recipe["id"], token!);
                                        _addNoteController.text = "";
                                        _changeOverlay(false);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.check),
                                      onPressed: () async {
                                        notes = await API.editNote(
                                            _notesController[note["id"]]!.text,
                                            recipe["id"],
                                            note['id'],
                                            token!);
                                        _addNoteController.text = "";
                                        _changeOverlay(false);
                                        print("object");
                                      },
                                    ),
                                  ],
                                );
                              })
                        else
                          for (var note in notes!)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  editNote
                                      ? Column()
                                      : Column(
                                          children: [
                                            Text(
                                              note["note"],
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Text(
                                              "-----------------------------",
                                            ),
                                          ],
                                        ),
                                ],
                              ),
                            ),
                      ] else
                        Flexible(
                          child: Column(
                            children: [
                              SizedBox(
                                width: 200,
                                height: 200,
                                child: TextFormField(
                                  controller: _addNoteController,
                                  focusNode: _addNotefocusNode,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your note',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 5,
                                  minLines: 1,
                                  keyboardType: TextInputType.multiline,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    child: IconButton(
                                      icon: Icon(Icons.close),
                                      onPressed: () {
                                        _changeOverlay(false);
                                      },
                                      padding: EdgeInsets.all(25),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.check),
                                    onPressed: () async {
                                      notes = await API.addNote(
                                          _addNoteController.text,
                                          recipe["id"],
                                          token!);
                                      _addNoteController.text = "";
                                      _changeOverlay(false);
                                    },
                                    padding: EdgeInsets.all(25),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addSelectedSList() {
    print("_showAddNoteOverlay");
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }
    _overlayEntry = _addSelectedSListOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _freezeOverlay() {
    print("_showAddNoteOverlay");
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }
    _overlayEntry = _freezeOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _freezeOverlayEntry() {
    return OverlayEntry(
        builder: (context) => Positioned(
            width: MediaQuery.of(context).size.width / 1.3,
            top: MediaQuery.of(context).size.height / 3.5,
            left: MediaQuery.of(context).size.width / 8,
            child: Material(
                elevation: 4.0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text("FREEZING"),
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
                        TextFormField(
                            controller: _freezePortions,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Enter the amount',
                              border: OutlineInputBorder(),
                            )),
                        TextFormField(
                            controller: _freezePortionsCategory,
                            focusNode: _freezePortionsCategoryfocusNode,
                            decoration: InputDecoration(
                              hintText: 'Enter categories',
                              border: OutlineInputBorder(),
                            )),
                        Text("Choosen categories:"),
                        if (freezerCategories != null) ...[
                          for (var category in freezerCategories!)
                            Text(category),
                        ],
                        IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () {
                            setState(() {
                              API.freezeItem(_freezePortions.text,
                                  recipe["name"], freezerCategories, token);
                              _removeOverlay();
                            });
                            KeepScreenOn.turnOn();
                            setState(() {
                              cook = true;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ))));
  }

  OverlayEntry _addSelectedSListOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width / 1.3,
        top: MediaQuery.of(context).size.height / 3.5,
        left: MediaQuery.of(context).size.width / 8,
        child: Material(
          elevation: 4.0,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 400, // Maximum height for the suggestions list
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text("SELECT INGRIDIENTS "),
                    IconButton(
                      icon: Icon(!canEditSelect ? Icons.edit : Icons.edit_note),
                      onPressed: () {
                        setState(() {
                          canEditSelect = !canEditSelect;
                          _addSelectedSList();
                        });
                      },
                    ),
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
                Expanded(
                  child: ListView.builder(
                    itemCount: recipe["ingredients"].length,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                          key: ValueKey(index),
                          title: Row(
                            children: [
                              canEditSelect
                                  ? Expanded(
                                      child: TextFormField(
                                          controller: _amountsController[index],
                                          focusNode: _addNotefocusNode,
                                          decoration: InputDecoration(
                                            hintText: 'Enter your note',
                                            border: OutlineInputBorder(),
                                          )),
                                    )
                                  : Text(recipe["amounts"][index] + "   "),
                              Text(recipe["ingredients"][index]),
                            ],
                          ),
                          value: _checkedValues[index],
                          onChanged: (bool? newValue) {
                            _checkedValues[index] = newValue ?? false;
                            if (_checkedValues[index] == true) {
                              _selectedIngredients[index] =
                                  recipe["ingredients"][index];
                              _selectedAmounts[index] =
                                  _amountsController[index] != null
                                      ? _amountsController[index]!.text
                                      : "";
                            } else if (_checkedValues[index] == false &&
                                _selectedIngredients.containsKey(index)) {
                              _selectedIngredients.remove(index);
                              _selectedAmounts.remove(index);
                            }
                            _addSelectedSList();
                          });
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    setState(() {
                      List<String> amounts = [];
                      List<String> ingredients = [];

                      // Iterating over the map using for-in
                      for (var entry in _selectedAmounts.entries) {
                        var key = entry.key;
                        var value = entry.value;

                        amounts.add(_selectedAmounts[key]!);
                        ingredients.add(_selectedIngredients[key]!);
                      }

                      API.addToSList(ingredients, amounts, token!);
                      _removeOverlay();
                      _checkedValues = [];
                      _selectedAmounts = {};
                      _selectedIngredients = {};
                      _checkedValues = List<bool>.filled(
                          recipe["ingredients"].length, false);
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
/*
  String calucateTime(var type) {
    return (int.parse(recipe[type]) < 60)
        ? "${recipe[type]} min"
        : "${(int.parse(recipe[type]) / 60).toStringAsFixed(2)} hours";
  }

  String totalTime() {
    return recipe["prep_time"] != null && recipe["cook_time"] != null
        ? int.parse(recipe["prep_time"]) + int.parse(recipe["cook_time"]) > 60
            ? "${((int.parse(recipe["prep_time"]) +
                                int.parse(recipe["cook_time"])) /
                            60)
                        .toStringAsFixed(2)} hours"
            : "${int.parse(recipe["prep_time"]) + int.parse(recipe["cook_time"])} min"
        : "Undefined";
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 255, 152, 0),
          toolbarHeight: 100,
          title: Text(
            recipe["name"] ?? 'Recipe Details',
            style: TextStyle(fontSize: 20),
            maxLines: 2, // Limit to a sensible number of lines
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Aligns text to the start
                  children: <Widget>[
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 17.0, bottom: 10),
                      child: Row(
                        children: [
                          CircularOrangeButton(
                            icon: Icons.archive,
                            onPressed: () {
                              _freezeOverlay();
                            },
                          ),
                          // if(recipe["userid"] == )
                          CircularOrangeButton(
                            icon: (!edit ? Icons.edit : Icons.edit_note),
                            onPressed: () {
                              setState(() {
                                edit = !edit;
                              });
                            },
                          ),
                          CircularOrangeButton(
                            icon: Icons.notes,
                            onPressed: () {
                              _showAddNoteOverlay();
                            },
                          ),
                          CircularOrangeButton(
                            icon: (!addedToList ? Icons.add : Icons.done),
                            onPressed: () {
                              _addSelectedSList();
                            },
                          ),
                          !addedToList
                              ? CircularOrangeButton(
                                  icon: Icons.add_box,
                                  onPressed: () async {
                                    int? result = await API.addToSList(
                                        recipe["ingredients"],
                                        recipe["amounts"],
                                        token!);
                                    if (result == 0) {
                                      setState(() {
                                        addedToList = true;
                                      });
                                    }
                                  },
                                )
                              : CircularOrangeButton(
                                  icon: Icons.done,
                                  onPressed: () {},
                                ),
                          CircularOrangeButton(
                            icon: Icons.share,
                            onPressed: () {
                               createAndSharePdf();
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 20, top: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        color: Color.fromARGB(255, 215, 184, 152),
                      ),
                      width: MediaQuery.sizeOf(context).width - 40,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            
                            !edit
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start, // Ensures alignment to the start
                                    children: [
                                      Text(
                                        "Preparation time: ${recipe["prep_time"]?.toString() ?? "Unknown"} min",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        "Cooking time: ${recipe["cook_time"]?.toString() ?? "Unknown"} min",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      TextFormField(
                                        controller: _prepTimeController,
                                        focusNode: _prepTimefocusNode,
                                        decoration: InputDecoration(
                                          border: UnderlineInputBorder(),
                                          labelText:
                                              'Enter preparation time [min]',
                                        ),
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      TextFormField(
                                        controller: _cookTimeController,
                                        focusNode: _cookTimefocusNode,
                                        decoration: InputDecoration(
                                          border: UnderlineInputBorder(),
                                          labelText:
                                              'Enter preparation time [min]',
                                        ),
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                            Text(
                              "Total time: ${recipe["total_time"]}",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "TOTAL CALORIES: ${recipe["calories"] ?? "Unknown"}",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    !edit
                        ? IngredientsSection(
                            ingredients: recipe["ingredients"],
                            amounts: recipe["amounts"])
                        : Container(
                          margin: const EdgeInsets.only(left: 20, top: 3, right: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: Color.fromARGB(255, 215, 184, 152),
      ),
                          child: Column(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.check),
                                  onPressed: () async {
                                    updateIngredients();
                                  },
                                ),
                                ListView.builder(
                                   physics:
                                                NeverScrollableScrollPhysics(), 
                                    shrinkWrap: true,
                                    itemCount: recipe["ingredients"].length,
                                    itemBuilder: (context, index) {
                                      final item = recipe["ingredients"][index];
                                      return ListTile(
                                        title: Row(
                                          children: [
                                            Flexible(
                                                child: TextFormField(
                                                  controller:
                                                      _controllersQTY[index],
                                                  decoration: InputDecoration(
                                                    border:
                                                        UnderlineInputBorder(),
                                                  ),
                                                )),
                                            Flexible(
                                                child: TextFormField(
                                                  controller:
                                                      _controllersITM[index],
                                                  decoration: InputDecoration(
                                                    border:
                                                        UnderlineInputBorder(),
                                                  ),
                                                )),
                                          ],
                                        ),
                                      );
                                    }),
                              ],
                            ),
                        ),
                    SizedBox(height: 8),
                    Container(
                        width: MediaQuery.sizeOf(context).width - 40,
                        margin:
                            const EdgeInsets.only(left: 20, top: 3, bottom: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          color: Color.fromARGB(255, 215, 184, 152),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!edit)
                                ..._parseInstructions(
                                    recipe["instructions"] ?? "")
                              else
                                Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.check),
                                      onPressed: () async {
                                        updateInstructions();
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        keyboardType: TextInputType.multiline,
                                        maxLines: null,
                                        controller: _instructionsController,
                                        decoration: InputDecoration(
                                          border: UnderlineInputBorder(),
                                          labelText: 'Enter instructions',
                                        ),
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: GestureDetector(
          onTap: () {
            API.cook(recipe["ingredients"], recipe["amounts"], token!);
            KeepScreenOn.turnOn();
            setState(() {
              cook = true;
            });
          },
          child: Container(
              height: 60.0,
              width: 60.0,
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle, // Make the container circular
              ),
              child: Center(
                child: Icon(
                  !cook ? Icons.microwave : Icons.done,
                  size: 20,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              )),
        ));
  }
}

List<Widget> _parseInstructions(String instructions) {
  List<String> instructionList =
      instructions.split('.').where((s) => s.trim().isNotEmpty).toList();

  return instructionList.map((instruction) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, left: 20.0),
      child: Text(
        "${instruction.trim()}.",
        style: TextStyle(fontSize: 20),
      ),
    );
  }).toList();
}

class IngredientsSection extends StatelessWidget {
  final List<dynamic> ingredients;
  final List<dynamic> amounts;

  IngredientsSection({required this.ingredients, required this.amounts});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, top: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: Color.fromARGB(255, 215, 184, 152),
      ),
      width: MediaQuery.sizeOf(context).width - 40,
      child: Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (var i = 0; i < ingredients.length; i++)
            Container(
              margin: const EdgeInsets.only(left: 20, top: 3),
              child: Text(
                "${amounts[i] ?? ""} x ${ingredients[i] ?? ""}",
                style: TextStyle(fontSize: 16),
              ),
            ),
        ]),
      ),
    );
  }
}

class editIngredientsSection extends StatelessWidget {
  final List<dynamic> ingredients;
  final List<dynamic> amounts;

  editIngredientsSection({required this.ingredients, required this.amounts});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, top: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: Color.fromARGB(255, 215, 184, 152),
      ),
      width: MediaQuery.sizeOf(context).width - 40,
      child: Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (var i = 0; i < ingredients.length; i++)
            Container(
              margin: const EdgeInsets.only(left: 20, top: 3),
              child: Text(
                "${amounts[i] ?? ""} x ${ingredients[i] ?? ""}",
                style: TextStyle(fontSize: 16),
              ),
            ),
        ]),
      ),
    );
  }
}

class CircularOrangeButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  CircularOrangeButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 215, 184, 152),
          shape: BoxShape.circle, // Circular shape
        ),
        child: IconButton(
          icon: Icon(icon,
              size: 25.0, color: Colors.white), // White icon color for contrast
          onPressed: onPressed,
        ),
      ),
    );
  }
}
