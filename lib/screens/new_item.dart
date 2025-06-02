import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';

class NewItemScreen extends StatefulWidget {
  const NewItemScreen({super.key});

  @override
  State<NewItemScreen> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  var _selectedName = '';
  var _selectedQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;

  void _saveItem() async {
    final isValidated = _formKey.currentState!.validate();

    if (isValidated) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      final url = Uri.https(
        'flutter-prep-1b93c-default-rtdb.firebaseio.com',
        'shopping-list.json',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _selectedName,
          'quantity': _selectedQuantity,
          'category': _selectedCategory.title,
        }),
      );
      setState(() {
        _isLoading = false;
      });

      final data = json.decode(response.body);

      if (!context.mounted) return;

      Navigator.of(context).pop(
        GroceryItem(
          id: data['name'],
          name: _selectedName,
          quantity: _selectedQuantity,
          category: _selectedCategory,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a new item')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: _selectedName,
                maxLength: 50,
                decoration: const InputDecoration(label: Text('Name')),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  _selectedName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      initialValue: _selectedQuantity.toString(),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must be a valid, positive number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _selectedQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16.0,
                                  height: 16.0,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 6.0),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isLoading
                            ? null
                            : () {
                              _formKey.currentState!.reset();
                            },
                    child: const Text('Reset'),
                  ),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveItem,
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(),
                            )
                            : const Text('Add Item'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
