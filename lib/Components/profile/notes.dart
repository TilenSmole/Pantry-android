import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:http/http.dart' as http;
import '../load_token.dart' as load_token;
import '../../main.dart';
import './API/profileAPI.dart' as API;

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
    var result = await await API.getNotes(token);
    print("result");
    setState(() {
      notes = result;
    });

    print(notes);
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
    Overlay.of(context)!.insert(_overlayEntry!);
  }

  void addNote() async {
    var result = await API.addNote(_newNoteController.text, token!);

    setState(() {
      notes = result;
    });
  }

  OverlayEntry _createOverlayEntry() {
    print("creating overlay");

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
          title: Text('YOUR COOKING  NOTES'),
        ),
        body: Column(
          children: [
            Flexible(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final noteText =
                        note['note'] ?? 'No note'; 
                    return Container(
                      margin: const EdgeInsets.only(
                          bottom: 20, left: 20, right: 20),
                      decoration: BoxDecoration(boxShadow: [
                        
                      ], border: Border.all(color: Colors.orange),
                       borderRadius: BorderRadius.all(Radius.circular(15))
                      ),
                      child: ListTile(
                        title: Text(noteText.toString()), // Display note text
                      ),
                    );
                  }),
            ),
          ],
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
