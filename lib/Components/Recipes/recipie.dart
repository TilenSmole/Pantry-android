import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'caloriesCalculator.dart';
import './API/recipeAPI.dart' as API;
import '../load_token.dart' as load_token;

class Recepie extends StatefulWidget {
  final Map<String, dynamic> recipe;
  Recepie({Key? key, required this.recipe}) : super(key: key);
  @override
  State<StatefulWidget> createState() => RecepieState(recipe);
}

class RecepieState extends State<Recepie> {
  final Map<String, dynamic> recipe;
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

    print("_notesController");
    print(_notesController);
  }

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  void _showAddNoteOverlay() {
    print("_showAddNoteOverlay");
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }
    _overlayEntry = _createAddNoteOverlayEntry();
    Overlay.of(context)!.insert(_overlayEntry!);
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
    print("_createAddNoteOverlayEntry");

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
                                    Container(
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
                                      onPressed: ()  async{
                                          notes = await API.deleteNote(
                                              note["id"], recipe["id"], token!);
                                          _addNoteController.text = "";
                                          _changeOverlay(false);
                                      
                                      },
                                    ),
                                     IconButton(
                                      icon: Icon(Icons.check),
                                      onPressed: ()  async{
                                          notes = await API.editNote(_notesController[note["id"]]!.text, recipe["id"],note['id'], token!);
                                          _addNoteController.text = "";
                                          _changeOverlay(false);
                                      
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
                                      : Text(
                                          note["note"],
                                          style: TextStyle(fontSize: 16),
                                        ),
                                ],
                              ),
                            ),
                      ] else
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            children: [
                              Expanded(
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
                              // Handle button press
                            },
                          ),
                          CircularOrangeButton(
                            icon: Icons.edit,
                            onPressed: () {
                              // Handle button press
                            },
                          ),
                          CircularOrangeButton(
                            icon: Icons.notes,
                            onPressed: () {
                              _showAddNoteOverlay();
                            },
                          ),
                          CircularOrangeButton(
                            icon: Icons.add,
                            onPressed: () {
                              // Handle button press
                            },
                          ),
                          !addedToList
                              ? CircularOrangeButton(
                                  icon: Icons.add_box,
                                  onPressed: () async {
                                    print(recipe);
                                    int? result = await API.addToSList(
                                        recipe["ingredients"],
                                        recipe["amounts"],
                                        token!);
                                    print(result);
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
                              // Handle button press
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 20, top: 3),
                      decoration: new BoxDecoration(
                        borderRadius: new BorderRadius.circular(16.0),
                        color: Color.fromARGB(255, 215, 184, 152),
                      ),
                      width: MediaQuery.sizeOf(context).width - 40,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Preparation time: ${recipe["prep_time"] ?? "Unknown"}",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 8), // Adds space between texts
                            Text(
                              "Cooking time: ${recipe["cook_time"] ?? "Unknown"}",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 8), // Adds space between texts
                            Text(
                              "Total time: ${recipe["total_time"] ?? "Unknown"}", // Fixed key from "cook_time" to "total_time"
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "TOTAL CALORIES: ${caloriesCalculator(recipe["ingredients"]).getCalories() ?? "Unknown"}", // Fixed key from "cook_time" to "total_time"
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    IngredientsSection(
                        ingredients: recipe["ingredients"],
                        amounts: recipe["amounts"]),
                    SizedBox(height: 8),
                    Container(
                        width: MediaQuery.sizeOf(context).width - 40,
                        margin:
                            const EdgeInsets.only(left: 20, top: 3, bottom: 20),
                        decoration: new BoxDecoration(
                          borderRadius: new BorderRadius.circular(16.0),
                          color: Color.fromARGB(255, 215, 184, 152),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ..._parseInstructions(
                                  recipe["instructions"] ?? ""),
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
          onTap: () {},
          child: Container(
              height: 60.0,
              width: 60.0,
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle, // Make the container circular
              ),
              child: Center(
                child: Icon(
                  Icons.microwave,
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
                "${amounts[i] != null ? amounts[i] : ""} x ${ingredients[i] != null ? ingredients[i] : ""}",
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
