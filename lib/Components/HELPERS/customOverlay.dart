import 'package:flutter/material.dart';
import '../../colors.dart';

class CustomOverlay {
  final BuildContext context;
  final TextEditingController controller;
  final VoidCallback onSave;
  final String title;
  OverlayEntry? _overlayEntry;

  CustomOverlay({
    required this.context,
    required this.controller,
    required this.onSave,
    required this.title,
  });

  void show() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [// Dim background to focus on the overlay
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
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.grey),
                          onPressed: hide,
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: "Enter $title",
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

                    SizedBox(height: 15),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: C.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      ),
                      icon: Icon(Icons.check, color: Colors.white),
                      label: Text(
                        "Save $title",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          onSave();
                          controller.clear();
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
