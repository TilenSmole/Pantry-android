import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:flutter/material.dart';
import 'API/recipe_api.dart' as API;
import '../load_token.dart' as load_token;
import '../../colors.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../HELPERS/custom_overlay.dart';
import '../HELPERS/custom_overlay.dart';

// ignore: must_be_immutable
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
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => RecepieState(recipe);
}

class RecepieState extends State<Recepie> {
  Map<String, dynamic> recipe;
  RecepieState(this.recipe);
  String? token;
  bool addedToList = false;
  OverlayEntry? _overlayEntry;

  final FocusNode _addNotefocusNode = FocusNode();
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
  bool canEditSelect = false;

  //freeze
  TextEditingController _freezePortions = TextEditingController();

  //edit main
  bool edit = false;
  TextEditingController _prepTimeController = TextEditingController();
  FocusNode _prepTimefocusNode = FocusNode();
  TextEditingController _cookTimeController = TextEditingController();
  FocusNode _cookTimefocusNode = FocusNode();
  TextEditingController _instructionsController = TextEditingController();

  Map<int, TextEditingController> _controllersQTY = {};
  Map<int, TextEditingController> _controllersITM = {};

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
  }

  void _updateIngredient(int index) {
    recipe["ingredients"][index] = _controllersITM[index]!.text;
    recipe["amounts"][index] = _controllersQTY[index]!.text;
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
                child: pw.Column(
                  children: [
                    for (var i = 0; i < recipe["ingredients"].length; i++)
                      pw.Text(
                        "${recipe["amounts"][i] ?? ''} ${recipe["ingredients"][i] ?? ''}",
                      ),
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
    var result = await API.editPrepTime(
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
    var result = await API.editCookTime(
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
        width: MediaQuery.of(context).size.width * 0.9,
        top: MediaQuery.of(context).size.height * 0.2,
        right: MediaQuery.of(context).size.width * 0.05,
        child: Material(
          elevation: 10,
          color: Colors
              .transparent, // Make Material's color transparent so that the Container's background color is visible
          child: Container(
            height: 700,
            decoration: BoxDecoration(
              color: Colors.black, // Background color of the Container
              borderRadius: BorderRadius.circular(16.0), // Rounded corners
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
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
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: C.darkGrey,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                hintText: 'Enter your note...',
                                              ),
                                              maxLines:
                                                  null, // Allows the TextFormField to expand vertically
                                              keyboardType:
                                                  TextInputType.multiline,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.delete),
                                              onPressed: () async {
                                                notes = await API.deleteNote(
                                                    note["id"],
                                                    recipe["id"],
                                                    token!);
                                                _addNoteController.text = "";
                                                _changeOverlay(false);
                                              },
                                              padding: EdgeInsets.all(15),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.check),
                                              onPressed: () async {
                                                notes = await API.editNote(
                                                    _notesController[
                                                            note["id"]]!
                                                        .text,
                                                    recipe["id"],
                                                    note['id'],
                                                    token!);
                                                _addNoteController.text = "";
                                                _changeOverlay(false);
                                              },
                                              padding: EdgeInsets.all(15),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            })
                      else
                        for (var note in notes!)
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: C.darkGrey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (editNote)
                                  Column(
                                    children: [
                                      // You can add a TextField or editing UI here
                                      Text(
                                        'Editing...',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  )
                                else
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        note["note"],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                    ] else
                      Flexible(
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: C.darkGrey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: TextFormField(
                                  controller: _addNoteController,
                                  focusNode: _addNotefocusNode,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your note',
                                    hintStyle: TextStyle(color: Colors.white60),
                                    filled: true,
                                    fillColor: C.darkGrey.withOpacity(0.6),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Colors.white30),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: Colors.orangeAccent),
                                    ),
                                  ),
                                  style: TextStyle(color: Colors.white),
                                  maxLines: 5,
                                  minLines: 1,
                                  keyboardType: TextInputType.multiline,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.close,
                                        color: Colors.white70),
                                    onPressed: () {
                                      _changeOverlay(false);
                                    },
                                    padding: EdgeInsets.all(20),
                                  ),
                                  IconButton(
                                    icon:
                                        Icon(Icons.check, color: Colors.white),
                                    onPressed: () async {
                                      notes = await API.addNote(
                                        _addNoteController.text,
                                        recipe["id"],
                                        token!,
                                      );
                                      _addNoteController.text = "";
                                      _changeOverlay(false);
                                    },
                                    padding: EdgeInsets.all(20),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
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
    CustomOverlay(
      context: context,
      controllers: [_freezePortions],
      onSave: () async {
        await API.freezeItem(
            _freezePortions.text, recipe["name"], "Freezer", token);
      },
      title: "Freezing",
      hintTexts: ["Enter number of portions that will be added to Freezer"],
    ).show();
  }

  void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _addSelectedSListOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: hide,
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),
          Positioned(
            width: MediaQuery.of(context).size.width * 0.8,
            top: MediaQuery.of(context).size.height * 0.3,
            left: MediaQuery.of(context).size.width * 0.1,
            child: Material(
              borderRadius: BorderRadius.circular(20),
              elevation: 10,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("SELECT INGREDIENTS "),
                        IconButton(
                          icon: Icon(
                              !canEditSelect ? Icons.edit : Icons.edit_note),
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
                      child: Container(
                        decoration: BoxDecoration(
                          color: C.darkGrey,
                          borderRadius: BorderRadius.circular(20),
                        ),
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
                                            controller:
                                                _amountsController[index],
                                            focusNode: _addNotefocusNode,
                                            decoration: InputDecoration(
                                              hintText: 'Enter your note',
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                        )
                                      : Text(recipe["amounts"][index] + "   "),
                                  Text(recipe["ingredients"][index]),
                                ],
                              ),
                              value: _checkedValues[index],
                              onChanged: (bool? newValue) {
                                _checkedValues[index] = newValue ?? false;
                                if (_checkedValues[index]) {
                                  _selectedIngredients[index] =
                                      recipe["ingredients"][index];
                                  _selectedAmounts[index] =
                                      _amountsController[index]?.text ?? "";
                                } else {
                                  _selectedIngredients.remove(index);
                                  _selectedAmounts.remove(index);
                                }
                                _addSelectedSList();
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () {
                        setState(() {
                          List<String> amounts = [];
                          List<String> ingredients = [];

                          for (var entry in _selectedAmounts.entries) {
                            var key = entry.key;
                            amounts.add(_selectedAmounts[key]!);
                            ingredients.add(_selectedIngredients[key]!);
                          }

                          API.addToSList(ingredients, amounts, token!);
                          _removeOverlay();
                          _checkedValues = List<bool>.filled(
                              recipe["ingredients"].length, false);
                          _selectedAmounts.clear();
                          _selectedIngredients.clear();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: C.orange,
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
                        color: C.darkGrey,
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
                            margin: const EdgeInsets.only(
                                left: 20, top: 3, right: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              color: C.darkGrey,
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
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: recipe["ingredients"].length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Row(
                                          children: [
                                            Flexible(
                                                child: TextFormField(
                                              controller:
                                                  _controllersQTY[index],
                                              decoration: InputDecoration(
                                                border: UnderlineInputBorder(),
                                              ),
                                            )),
                                            Flexible(
                                                child: TextFormField(
                                              controller:
                                                  _controllersITM[index],
                                              decoration: InputDecoration(
                                                border: UnderlineInputBorder(),
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
                          color: C.darkGrey,
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
                color: C.orange,
                shape: BoxShape.circle,
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
        color: C.darkGrey,
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

class EditIngredientsSection extends StatelessWidget {
  final List<dynamic> ingredients;
  final List<dynamic> amounts;

  EditIngredientsSection({required this.ingredients, required this.amounts});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, top: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: C.darkGrey,
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
          color: C.darkGrey,
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
