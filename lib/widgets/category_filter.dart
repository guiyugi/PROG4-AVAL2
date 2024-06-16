import 'package:flutter/material.dart';

class CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const CategoryFilter({
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedCategory,
      onChanged: (String? newCategory) {
        if (newCategory != null) {
          onCategoryChanged(newCategory);
        }
      },
      items: categories.map<DropdownMenuItem<String>>((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
    );
  }
}
