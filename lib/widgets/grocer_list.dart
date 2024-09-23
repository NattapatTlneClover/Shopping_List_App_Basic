// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shopping_list_app/data/categories.dart';
// import 'dart:convert';

// //import 'package:shopping_list_app/data/dummy_item.dart';
// import 'package:shopping_list_app/models/grocery_item.dart';
// import 'package:shopping_list_app/widgets/new_item.dart';

// class GroceryList extends StatefulWidget {
//   const GroceryList({super.key});

//   @override
//   State<GroceryList> createState() => _GroceryListState();
// }

// class _GroceryListState extends State<GroceryList> {
//   List<GroceryItem> _groceryItems = [];
//   var _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadItems();
//   }

//   void _loadItems() async {
//     final url = Uri.https(
//         'flutter-prep-d80b3-default-rtdb.asia-southeast1.firebasedatabase.app',
//         'shopping-list.json');
//     final response = await http.get(url);
//     print(response.body);
//     final Map<String, dynamic> listData = json.decode(response.body);
//     final List<GroceryItem> loadedItem = [];
//     for (final item in listData.entries) {
//       final category = categories.entries
//           .firstWhere(
//               (catItem) => catItem.value.title == item.value['category'])
//           .value;
//       loadedItem.add(
//         GroceryItem(
//           id: item.key,
//           name: item.value['name'],
//           quantity: item.value['quantity'],
//           category: category,
//         ),
//       );
//     }
//     _groceryItems = loadedItem;
//   }

//   void _addItem() async {
//     final newItem = await Navigator.of(context).push<GroceryItem>(
//       MaterialPageRoute(
//         builder: (ctx) => const NewItem(),
//       ),
//     );

//     if (newItem == null) {
//       return;
//     }

//     setState(() {
//       _groceryItems.add(newItem);
//       _isLoading = false;
//     });
//   }

//   void _removeItem(GroceryItem item) {
//     setState(() {
//       _groceryItems.remove(item);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     Widget content = const Center(
//       child: Text('No items added yet.'),
//     );

//     if (_isLoading) {
//       content = const Center(
//         child: CircularProgressIndicator(),
//       );
//     }

//     if (_groceryItems.isNotEmpty) {
//       content = ListView.builder(
//         itemCount: _groceryItems.length,
//         itemBuilder: (ctx, index) => Dismissible(
//           onDismissed: (direction) {
//             _removeItem(_groceryItems[index]);
//           },
//           key: ValueKey(_groceryItems[index].id),
//           child: ListTile(
//             title: Text(_groceryItems[index].name),
//             leading: Container(
//               width: 24,
//               height: 24,
//               color: _groceryItems[index].category.color,
//             ),
//             trailing: Text(
//               _groceryItems[index].quantity.toString(),
//             ),
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Your Groceries'),
//         actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
//       ),
//       body: content,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list_app/data/categories.dart';
import 'dart:convert';

import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  // Function to load grocery items from the server
  void _loadItems() async {
    final url = Uri.https(
      'flutter-prep-d80b3-default-rtdb.asia-southeast1.firebasedatabase.app',
      'shopping-list.json',
    );

    try {
      final response = await http.get(url);
      final Map<String, dynamic>? listData = json.decode(response.body);

      if (listData == null) {
        setState(() {
          _isLoading = false; // Set loading to false even if there's no data
        });
        return;
      }

      final List<GroceryItem> loadedItems = [];

      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
              (catItem) => catItem.value.title == item.value['category'],
            )
            .value;

        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }

      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false; // Set loading to false after data is loaded
      });
    } catch (error) {
      // Handle errors, e.g., show an error message
      print("Failed to load items: $error");
      setState(() {
        _isLoading = false; // Set loading to false in case of error
      });
    }
  }

  // Function to add a new item
  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (newItem == null) {
      return; // No new item added, exit
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  // Function to remove an item
  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https(
      'flutter-prep-d80b3-default-rtdb.asia-southeast1.firebasedatabase.app',
      'shopping-list/${item.id}.json',
    );

    final response = await http.delete(url);

    if(response.statusCode >= 400) {
      // Optional: Show error message
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //Logic
    Widget content = const Center(
      child: Text('No items added yet.'),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          key: ValueKey(_groceryItems[index].id),
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(
              _groceryItems[index].quantity.toString(),
            ),
          ),
        ),
      );
    }

    //UI
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}
