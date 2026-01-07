import 'package:flutter/material.dart';

/// Category selector widget with radio buttons or dropdown
class CategorySelector extends StatelessWidget {
  final String? selectedCategoryId;
  final List<Map<String, dynamic>> categories;
  final ValueChanged<String?> onChanged;

  const CategorySelector({
    Key? key,
    required this.selectedCategoryId,
    required this.categories,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Category',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    categories.map((category) {
                      final categoryId = category['id'] as String;
                      final isSelected = selectedCategoryId == categoryId;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(category['name'] as String),
                          selected: isSelected,
                          onSelected: (_) => onChanged(categoryId),
                          backgroundColor: Colors.grey[200],
                          selectedColor: Colors.blue.withOpacity(0.3),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
