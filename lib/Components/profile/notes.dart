import 'dart:async';
import 'package:flutter/material.dart';
import '../load_token.dart' as load_token;
import 'API/profile_api.dart' as API;
import '../HELPERS/add_button.dart';
import '../HELPERS/custom_overlay.dart';
import '../HELPERS/colors.dart';

class Notes extends StatefulWidget {
  @override
  NotesState createState() => NotesState();
}

class NotesState extends State<Notes> {
  String? token;
  List<Map<String, dynamic>> notes = [];
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

  void addNote() async {
    await API.addNote(_newNoteController.text, token!);
    getNote();
  }

  void editNote(int index, var noteId) async {
    if (_notesControllers[noteId]!.text.isNotEmpty) {
      print(_notesControllers[noteId]!.text);
      print(noteId);

     
          await API.editNote(_notesControllers[noteId]!.text, noteId, token!);

      _checkedValues[index] = !_checkedValues[index];

      getNote();
    }
  }

  void deleteNote(int index, var noteId) async {
    if (_notesControllers[noteId]!.text.isNotEmpty) {
      
          API.editNote(_notesControllers[noteId]!.text, noteId, token!);

      _checkedValues[index] = !_checkedValues[index];

      getNote();
    }
  }

  void _showAddNoteOverlay() {
    CustomOverlay(
      context: context,
      controllers: [_newNoteController],
      onSave: addNote,
      title: "New Note",
      hintTexts: ["Enter a note "],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'COOKING NOTES',
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
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final noteText = note['note'] ?? 'No note';
                    return _checkedValues[index]
                        ? Container(
                            margin: const EdgeInsets.only(
                                bottom: 20, left: 20, right: 20),
                            decoration: BoxDecoration(
                                color: C.darkGrey,
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
                                bottom: 10, left: 10, right: 10),
                            decoration: BoxDecoration(
                                boxShadow: [],
                                color: C.darkGrey,
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
      floatingActionButton: CustomFloatingButton(
        onTap: _showAddNoteOverlay, // Pass function reference
        color: C.orange, // Optional, defaults to orange
      ),
    );
  }
}
