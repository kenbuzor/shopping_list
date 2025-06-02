import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';

import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/screens/new_item.dart';
import 'package:shopping_list/widgets/grocery_list_item.dart';

class GroceriesScreen extends StatefulWidget {
  const GroceriesScreen({super.key});

  @override
  State<GroceriesScreen> createState() => _GroceriesScreenState();
}

class _GroceriesScreenState extends State<GroceriesScreen> {
  List<GroceryItem> _groceryItems = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
      'flutter-prep-1b93c-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'An error has occurred please try again later';
        });
      }

      final Map<String, dynamic>? dataList = json.decode(response.body);

      if (dataList == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final List<GroceryItem> loadedItems = [];

      for (final item in dataList.entries) {
        final category = categories.entries.firstWhere(
          (catItem) => catItem.value.title == item.value['category'],
        );
        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category.value,
          ),
        );
      }

      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Something went wrong!. Please try again later';
      });
    }
  }

  void _addItem() async {
    final result = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(builder: (ctx) => const NewItemScreen()),
    );

    if (result == null) return;

    setState(() {
      _groceryItems.add(result);
    });
  }

  void _deleteItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);

    setState(() {
      _groceryItems.removeAt(index);
    });

    final url = Uri.https(
      'flutter-prep-1b93c-default-rtdb.firebaseio.com',
      'shopping-list/${item.id}.json',
    );

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Padding(
      padding: EdgeInsets.all(32.0),
      child: Center(
        child: Text(
          'Your grocery list is empty. Click the + button above to add one',
          textAlign: TextAlign.center,
        ),
      ),
    );

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder:
            (ctx, i) =>
                GroceryListItem(item: _groceryItems[i], onSwipe: _deleteItem),
      );
    }

    if (_error != null) {
      content = Center(child: Text(_error!));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: content,
    );
  }
}
