import 'package:flutter/material.dart';
import '../../colors.dart';

class CustomOverlay {
  final BuildContext context;
  final List<TextEditingController> controllers;
  final List<String> hintTexts;
  final VoidCallback onSave;
  final String title;
  List<String>? categories;
  OverlayEntry? _overlayEntry;

  CustomOverlay({
    required this.context,
    required this.controllers,
    required this.onSave,
    required this.title,
    required this.hintTexts,
    this.categories,
  });

  void show() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: hide,
              child: Container(color: Colors.black),
            ),
          ),
          Positioned(
            width: MediaQuery.of(context).size.width * 0.8,
            top: MediaQuery.of(context).size.height * 0.3,
            left: MediaQuery.of(context).size.width * 0.1,
            child: Material(
              borderRadius: BorderRadius.circular(20),
              elevation: 10.0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: TextStyle(fontSize: 18),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.grey),
                          onPressed: hide,
                        ),
                      ],
                    ),

                    // Display the TextFormFields
                    ...controllers.asMap().entries.map((entry) {
                      int index = entry.key;
                      TextEditingController controller = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: hintTexts[index],
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 15,
                            ),
                          ),
                          maxLines: 3,
                          minLines: 2,
                          keyboardType: TextInputType.multiline,
                        ),
                      );
                    }).toList(),

                    // Conditionally display categories if not empty
                    if (categories != null && categories!.isNotEmpty) 
                      Column(
                        children: [
                          Text("Default lokacija za shranjevanje"),
                          DropdownButton<String>(
                            items: categories!.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                // API.changeDefaultCategory(widget.index, newValue);
                              }
                            },
                          ),
                        ],
                      ),

                    SizedBox(height: 15),

                    // Save button, placed after the category dropdown
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: C.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      ),
                      icon: Icon(Icons.check, color: Colors.white),
                      label: Text(
                        "Save $title",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onPressed: () {
                        bool allFilled = controllers.every((controller) => controller.text.isNotEmpty);
                        if (allFilled) {
                          onSave();
                          for (var controller in controllers) {
                            controller.clear();
                          }
                          hide();
                        }
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

    Overlay.of(context).insert(_overlayEntry!);
  }

  void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
