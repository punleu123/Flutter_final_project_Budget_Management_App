import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';

/// Screen for selecting a category
/// Returns selected category ID when user taps on a category
class CategorySelectionScreen extends ConsumerStatefulWidget {
  final String? initialSelectedId;

  const CategorySelectionScreen({Key? key, this.initialSelectedId})
    : super(key: key);

  @override
  ConsumerState<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState
    extends ConsumerState<CategorySelectionScreen> {
  late String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialSelectedId;
  }

  void _selectCategory(String categoryId) {
    // Return the selected category ID to the previous screen
    Navigator.of(context).pop(categoryId);
  }

  @override
  Widget build(BuildContext context) {
    // Load categories from provider
    final categoriesState = ref.watch(categoryProvider);
    final categories = categoriesState.categories;

    // Show empty state if no categories
    if (categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Select Category'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.category_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No categories available'),
              const SizedBox(height: 8),
              const Text(
                'Please create a category first',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Category'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategoryId == category.id;

          // Parse color from hex string
          final color = Color(int.parse('FF${category.color}', radix: 16));

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Card(
              elevation: isSelected ? 4 : 2,
              child: InkWell(
                onTap: () => _selectCategory(category.id),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border:
                        isSelected
                            ? Border.all(color: Colors.blue, width: 2)
                            : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Category Icon
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              category.icon,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Category Name
                        Expanded(
                          child: Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ),

                        // Selection Indicator
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.blue,
                            size: 28,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
