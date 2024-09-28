import 'package:flutter/material.dart';

class CategoryFilter extends StatelessWidget {
  final Function(String) onCategorySelected;

  const CategoryFilter({super.key, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    final categories = ['', 'business', 'entertainment', 'general', 'health', 'science', 'sports', 'technology'];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(categories[index].isEmpty ? 'All' : categories[index]),
              selected: false,
              onSelected: (_) => onCategorySelected(categories[index]),
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          );
        },
      ),
    );
  }
}