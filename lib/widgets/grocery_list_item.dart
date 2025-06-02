import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';

class GroceryListItem extends StatelessWidget {
  const GroceryListItem({super.key, required this.item, required this.onSwipe});

  final GroceryItem item;
  final void Function(GroceryItem item) onSwipe;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      background: Container(color: Colors.red),
      onDismissed: (_) {
        onSwipe(item);
      },
      child: ListTile(
        key: ValueKey(item.id),
        leading: Container(width: 30, height: 30, color: item.category.color),
        title: Text(
          item.name,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Text(
          '${item.quantity}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
