import 'package:flutter/material.dart';

SnackBar mySnackbar(BuildContext context, {required text, required undo}) {
  return SnackBar(
    backgroundColor: Theme.of(context).colorScheme.surface,
    content: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.labelLarge!.copyWith(color: Colors.white),
        ),
        TextButton(onPressed: undo, child: const Text('Undo')),
      ],
    ),
    duration: const Duration(seconds: 3),
  );
}
