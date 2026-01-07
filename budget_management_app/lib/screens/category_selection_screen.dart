import 'package:flutter/material.dart';

/// Represents a category for selection
class CategoryItem {
  final String id;
  final String name;
  final String icon;
  final Color color;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// Screen for selecting a category
/// Returns selected category ID when user taps on a category
class CategorySelectionScreen extends StatefulWidget {
  final String? initialSelectedId;

  const CategorySelectionScreen({Key? key, this.initialSelectedId})
    : super(key: key);

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  late String? _selectedCategoryId;

  // List of available categories
  static final List<CategoryItem> categories = [
    const CategoryItem(
      id: 'food',
      name: 'Food & Dining',
      icon: '🍔',
      color: Color(0xFFFFB84D),
    ),
    const CategoryItem(
      id: 'transport',
      name: 'Transportation',
      icon: '🚗',
      color: Color(0xFF4DB8FF),
    ),
    const CategoryItem(
      id: 'entertainment',
      name: 'Entertainment',
      icon: '🎬',
      color: Color(0xFFFF99CC),
    ),
    const CategoryItem(
      id: 'shopping',
      name: 'Shopping',
      icon: '🛍️',
      color: Color(0xFFCC99FF),
    ),
    const CategoryItem(
      id: 'utilities',
      name: 'Utilities',
      icon: '💡',
      color: Color(0xFFFFCC99),
    ),
    const CategoryItem(
      id: 'healthcare',
      name: 'Healthcare',
      icon: '🏥',
      color: Color(0xFF99FFCC),
    ),
    const CategoryItem(
      id: 'salary',
      name: 'Salary',
      icon: '💰',
      color: Color(0xFF99CC99),
    ),
    const CategoryItem(
      id: 'bonus',
      name: 'Bonus',
      icon: '🎁',
      color: Color(0xFFFFCC99),
    ),
  ];

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
                            color: category.color.withOpacity(0.2),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap to select',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),

                        // Selection Indicator
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: Colors.blue[600],
                            size: 28,
                          )
                        else
                          Icon(
                            Icons.radio_button_unchecked,
                            color: Colors.grey[400],
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
