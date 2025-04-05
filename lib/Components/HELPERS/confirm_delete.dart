import 'package:flutter/material.dart';

class ConfirmDeleteButton extends StatelessWidget {
  final String itemId;
  final int index;
  final String itemIdString;
  final String category;
  final Function(String, int, String, String) onDelete;

  ConfirmDeleteButton({
    required this.itemId,
    required this.index,
    required this.itemIdString,
    required this.category,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Confirm Deletion"),
                content: Text("Are you sure you want to delete this item?"),
                actions: <Widget>[
                  TextButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop(); 
                    },
                  ),
                  TextButton(
                    child: Text("Delete"),
                    onPressed: () {
                      onDelete(itemId, index, itemIdString, category);
                      Navigator.of(context)
                          .pop(); 
                    },
                  ),
                ],
              );
            },
          );
        },
        icon: Icon(Icons.delete));
  }
}
