import 'dart:async';
import 'package:flutter/material.dart';
import './API/item_add.dart' as API;
import './FoodDetailScreen.dart';
import '../HELPERS/colors.dart';

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

  // Search state
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

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
    // Filter storage items based on search query
    var filteredItems = _storage.entries.where((entry) {
      return entry.value["name"]
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: filteredItems.map((entry) {
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
                    await API.setDisallowdItems(index, value);
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
                    builder: (context) => FoodDetailScreen(
                        food: task,
                        checked: taskSelection[index] = value ?? false,
                        index: index),
                  ),
                );
              },
              child: Text(
                task["name"],
                style: TextStyle(fontSize: 16),
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
        title: Text(
          'Filter Storage',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: C.orange,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Search items...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      const Text(
                        'Saving only from storage: ',
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
