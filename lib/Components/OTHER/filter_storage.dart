import 'dart:async';
import 'package:flutter/material.dart';
import './API/item_add.dart' as API;
import './FoodDetailScreen.dart';

class FilterStorage extends StatefulWidget {
  @override
  _FilterStorageState createState() => _FilterStorageState();
}

class _FilterStorageState extends State<FilterStorage> {
  String? token;
  Map<int, dynamic> _storage = {};
  List<dynamic> _disallow_storage = [];

  Map<int, bool> taskSelection = {};
  bool enableOnlyStorageSaving = false;
  bool isLoading = true; 

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    Map<int, dynamic> fetchedItems = await API.getItems();
    List<dynamic> fetchedDisallowed = await API.getDisallowdItems();
    var enableOnlyStorageSavingCall = await API.getStorageOnly();

    setState(() {
      _storage = fetchedItems;
      _disallow_storage = fetchedDisallowed;
      enableOnlyStorageSaving = enableOnlyStorageSavingCall;

      taskSelection = Map.fromIterable(
        _storage.keys,
        value: (id) {
          return _disallow_storage
              .any((disallowedItem) => disallowedItem['disallowedId'] == id);
        },
      );
    isLoading = false;
      
    });

  }

  Widget buildTasksColumn() {
    return Column(
      children: _storage.entries.map((entry) {
        int index = entry.key;
        var task = entry.value;
        var value = taskSelection[index] ?? false;
        return Row(
          children: [
            StatefulBuilder(
              builder: (context, setState) {
                return Checkbox(
                  value: taskSelection[index] ?? false,
                  onChanged: (bool? value) async {
                    bool insert = await API.setDisallowdItems(index, value);
                    setState(() {
                      taskSelection[index] = value ?? false;
                    });
                  },
                );
              },
            ),
            GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodDetailScreen(food: task, checked: taskSelection[index] = value ?? false, index: index),
                    ),
                  );
                },
                child: Text(
                  task["name"],
                ),
              ),

          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filter Storage'),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      const Text(
                        'Enable saving only from storage: ',
                        style: TextStyle(fontSize: 17.0),
                      ),
                      Checkbox(
                        value: enableOnlyStorageSaving,
                        onChanged: (bool? value) async {
                          bool change = await API.setStorageOnly();
                          if (change) {
                            setState(() {
                              enableOnlyStorageSaving = value ?? false;
                            });
                          }
                        },
                      ),
                    ],
                  ),
            Expanded(
              child: SingleChildScrollView(
                child: buildTasksColumn(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
