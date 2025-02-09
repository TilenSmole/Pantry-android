import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './API/item_add.dart' as API;
import '../STORAGE/API/StorageAPI.dart' as STORAGE_API;

class FilterStorage extends StatefulWidget {
  @override
  _FilterStorageState createState() => _FilterStorageState();
}

class _FilterStorageState extends State<FilterStorage> {
  String? token;
  Map<int, String> _storage = {};
  List<dynamic> _disallow_storage = [];

  Map<int, bool> taskSelection = {};
  bool enableOnlyStorageSaving = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    Map<int, String> fetchedItems = await API.getItems();
    List<dynamic> fetchedDisallowed = await API.getDisallowdItems();

    setState(() {
      _storage = fetchedItems;
      _disallow_storage = fetchedDisallowed;

      taskSelection = Map.fromIterable(
      _storage.keys,  
      value: (id) {
        return _disallow_storage.any(
            (disallowedItem) => disallowedItem['disallowedId'] == id);
      },
    );

    });
    print(_disallow_storage);
  }

  Widget buildTasksColumn() {
    return Column(
      children: _storage.entries.map((entry) {
        int index = entry.key;
        var task = entry.value;

        return Row(
          children: [
            Checkbox(
              value: taskSelection[index] ?? false,
              onChanged: (bool? value) {},
            ),
            Text(task.toString()),
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
            Row(
              children: [
                const Text(
                  'Enable saving only from storage: ',
                  style: TextStyle(fontSize: 17.0),
                ),
                Checkbox(
                  value: enableOnlyStorageSaving,
                  onChanged: (bool? value) {},
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
