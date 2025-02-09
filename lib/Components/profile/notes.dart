import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:http/http.dart' as http;
import '../load_token.dart' as load_token;
import '../../main.dart';
import 'API/profileAPI.dart' as API;

class Notes extends StatefulWidget {
  @override
  _notesState createState() => _notesState();
}

class _notesState extends State<Notes> {
  String? token;
  List<Map<String, dynamic>> notes = [];
  OverlayEntry? _overlayEntry;
  LayerLink _newLayerController = LayerLink();
  TextEditingController _newNoteController = TextEditingController();

  List<bool> _checkedValues = [];
  Map<int, TextEditingController> _notesControllers = {};

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
    print(token);
    getNote();
  }

  void getNote() async {
    var result = await API.getNotes(token);
    print("result");
    setState(() {
      notes = result;
      _checkedValues = List<bool>.filled(notes.length, false);
    });

    for (var note in notes) {
      var controller = TextEditingController(text: note["note"]);
      setState(() {
        _notesControllers[note["id"]] = controller;
      });
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showAddNoteOverlay() {
    print("_showAddNoteOverlay");
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void addNote() async {
   await API.addNote(_newNoteController.text, token!);
    getNote();
  }

  void editNote(int index , var noteId) async {
    if (_notesControllers[noteId]!.text.isNotEmpty) {
      print(_notesControllers[noteId]!.text);
            print(noteId);

            var result =  await API.editNote(_notesControllers[noteId]!.text, noteId, token!);



         _checkedValues[index] = !_checkedValues[index];
     
  getNote();

    }
  }

 void deleteNote(int index , var noteId) async {
    if (_notesControllers[noteId]!.text.isNotEmpty) {
    

            var result =  API.editNote(_notesControllers[noteId]!.text, noteId, token!);

         _checkedValues[index] = !_checkedValues[index];
     
  getNote();

    }
  }



  OverlayEntry _createOverlayEntry() {
    LayerLink link = _newLayerController;
    return OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width / 1.5,
        top: MediaQuery.of(context).size.height / 3.5,
        left: MediaQuery.of(context).size.width / 6,
        child: Material(
          elevation: 4.0,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 300,
            ),
            child: Column(
              children: [
                Row(
                  children: [
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
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextFormField(
                      controller: _newNoteController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'New note',
                      ),
                      maxLines: 5,
                      minLines: 2,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    print(token);
                    if (_newNoteController.text.isNotEmpty && token != null) {
                      addNote();
                      _newNoteController.text = "";
                      _removeOverlay();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('YOUR COOKING  NOTES'),backgroundColor: Colors.orange,
        ),
        body: Container(
            margin: const EdgeInsets.only(
                                top: 20),
          child: Column(
            
            children: [
              Flexible(
                
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      final noteText = note['note'] ?? 'No note';
                      return _checkedValues[index]
                          ? Container(
                              margin: const EdgeInsets.only(
                                  bottom: 20, left: 20, right: 20),
                              decoration: BoxDecoration(
                                  color:  const Color.fromARGB(255, 235, 206, 162),
                                  boxShadow: [],
                                  border: Border.all(color: Colors.orange),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Spacer(),
                                       IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          setState(() {
                                            deleteNote(index, note["id"]);
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.close),
                                        onPressed: () {
                                          setState(() {
                                            _checkedValues[index] =
                                                !_checkedValues[index];
                                          });
                                        },
                                      ),
                                      
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      ListTile(
                                          title: TextFormField(
                                        controller: _notesControllers[note['id']],
                                        decoration: InputDecoration(
                                          border: UnderlineInputBorder(),
                                        ),
                                        maxLines: 5,
                                        minLines: 2,
                                        keyboardType: TextInputType.multiline,
                                      )),
                                      IconButton(
                                        icon: Icon(Icons.check),
                                        onPressed: () {
                                          setState(() {
                                            editNote(index, note["id"]);
                                          });
                                        },
                                      ),
                                      
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
                                  border: Border.all(color: Colors.orange),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
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
                                  ListTile(
                                    title: Text(
                                        noteText.toString()), // Display note text
                                  ),
                                ],
                              ),
                            );
                    }),
              ),
            ],
          ),
        ),
        floatingActionButton: GestureDetector(
          onTap: () {
            _showAddNoteOverlay();
          },
          child: Container(
              height: 80.0,
              width: 80.0,
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
