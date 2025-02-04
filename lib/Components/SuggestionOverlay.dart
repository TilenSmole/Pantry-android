import 'package:flutter/material.dart';
import './load_ingredients.dart';

class SuggestionOverlay {
  final TextEditingController textController;
  final Function(String) onSuggestionSelected;
  final BuildContext context;
  final LayerLink layerLink;
  OverlayEntry? _overlayEntry; // Make nullable to handle initialization timing
  List<String> _filteredSuggestions = [];
  List<String> allSuggestions = [];

  SuggestionOverlay({
    required this.textController,
    required this.onSuggestionSelected,
    required this.context,
    required this.layerLink,
  });


Future<void> loadFood() async {
          print("loadFood ");

    IngredientLoader loader = IngredientLoader();
    await Future.delayed(Duration(seconds: 1)); 
    allSuggestions = loader.allSuggestions;
  }



  void updateSuggestions() {
        print("updateSuggestions ");

    final query = textController.text.toLowerCase();
            print(query);

    _filteredSuggestions = allSuggestions.where((suggestion) {
      return suggestion.toLowerCase().contains(query);
    }).toList();


    if (_filteredSuggestions.isNotEmpty) {
      showOverlay();
    } else {
      removeOverlay();
    }
  }

  void showOverlay() {
        print("showOverlay ");

    // Remove existing overlay if it exists
    _overlayEntry?.remove();

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void removeOverlay() {
            print("removeOverlay ");

    // Check if _overlayEntry is not null before attempting to remove it
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null; // Set to null after removal
    }
  }

  OverlayEntry _createOverlayEntry() {
    print("_createOverlayEntry ");
    return OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width,
        child: CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60), // Adjust the vertical offset as needed
          child: Material(
            elevation: 4.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 200, // Maximum height for the suggestions list
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredSuggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_filteredSuggestions[index]),
                    onTap: () {
                      textController.text = _filteredSuggestions[index];
                      //onSuggestionSelected(_filteredSuggestions[index]);
                      _filteredSuggestions =
                          []; // Clear suggestions after selection
                      removeOverlay();
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
}
