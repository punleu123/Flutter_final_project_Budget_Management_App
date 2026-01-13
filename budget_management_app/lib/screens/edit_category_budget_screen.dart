import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../providers/category_budget_provider.dart';
import '../providers/category_provider.dart';
import '../providers/budget_provider.dart';
import '../core/currency_formatter.dart';

/// Screen for editing category budget targets
class EditCategoryBudgetScreen extends ConsumerStatefulWidget {
  final String? selectedCategoryId;

  const EditCategoryBudgetScreen({Key? key, this.selectedCategoryId})
    : super(key: key);

  @override
  ConsumerState<EditCategoryBudgetScreen> createState() =>
      _EditCategoryBudgetScreenState();
}

class _EditCategoryBudgetScreenState
    extends ConsumerState<EditCategoryBudgetScreen> {
  late TextEditingController _budgetController;
  late String _selectedCategoryId;
  late bool _applyToAllMonths;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _budgetController = TextEditingController();
    _selectedCategoryId = widget.selectedCategoryId ?? '';
    _applyToAllMonths = true;
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _saveBudget() async {
    if (_selectedCategoryId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    if (_budgetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a budget amount')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final budget = double.parse(_budgetController.text);

      if (budget <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget amount must be greater than 0')),
        );
        return;
      }

      if (_applyToAllMonths) {
        // Update template budget
        await ref
            .read(categoryBudgetProvider.notifier)
            .setTemplateBudget(_selectedCategoryId, budget);
      } else {
        // Update monthly override for current month
        final now = DateTime.now();
        await ref
            .read(categoryBudgetProvider.notifier)
            .setMonthlyOverride(
              _selectedCategoryId,
              now.month,
              now.year,
              budget,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budget updated successfully!'),
            duration: Duration(seconds: 2),
          ),
        );

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } on FormatException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(settingsProvider).currency;
    final currencyPrefix = currency == 'USD' ? '\$ ' : '៛ ';

    // Watch all categories from the provider
    final categoriesState = ref.watch(categoryProvider);

    // Set first category as default if not already selected
    if (_selectedCategoryId.isEmpty && categoriesState.categories.isNotEmpty) {
      _selectedCategoryId = categoriesState.categories.first.id;
    }

    // Return early if no categories exist
    if (categoriesState.categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Budget Target'), elevation: 0),
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    // Get current budget and spending for selected category
    final selectedCategory = categoriesState.categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
      orElse: () => categoriesState.categories.first,
    );

    final now = DateTime.now();
    final currentBudget = ref
        .read(categoryBudgetProvider.notifier)
        .getTarget(_selectedCategoryId, now.month, now.year);

    final spent = ref.watch(
      categorySpendingProvider((_selectedCategoryId, now.month, now.year)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Budget Target'), elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Category',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      categoriesState.categories.isEmpty
                          ? Center(
                            child: Text(
                              'No categories found. Create one first.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          )
                          : DropdownButton<String>(
                            value: _selectedCategoryId,
                            isExpanded: true,
                            items:
                                categoriesState.categories
                                    .map(
                                      (category) => DropdownMenuItem(
                                        value: category.id,
                                        child: Text(category.name),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedCategoryId = value;
                                  _budgetController.clear();
                                });
                              }
                            },
                          ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Budget Amount Input
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Budget Amount',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              currency,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _budgetController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter budget amount',
                          prefixText: currencyPrefix,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Set the target budget for this category',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Apply To Option
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Apply To',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      RadioListTile<bool>(
                        title: const Text('All Future Months'),
                        subtitle: const Text(
                          'Update the default budget template',
                        ),
                        value: true,
                        groupValue: _applyToAllMonths,
                        onChanged: (value) {
                          setState(() {
                            _applyToAllMonths = value ?? true;
                          });
                        },
                      ),
                      RadioListTile<bool>(
                        title: const Text('This Month Only'),
                        subtitle: const Text(
                          'Override budget for current month only',
                        ),
                        value: false,
                        groupValue: _applyToAllMonths,
                        onChanged: (value) {
                          setState(() {
                            _applyToAllMonths = value ?? true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Current Budget Display
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Information',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Category:', selectedCategory.name),
                      _buildInfoRow(
                        'Current Budget:',
                        CurrencyFormatter.format(
                          currentBudget,
                          currency: currency,
                        ),
                      ),
                      _buildInfoRow(
                        'Spent This Month:',
                        CurrencyFormatter.format(spent, currency: currency),
                      ),
                      _buildInfoRow(
                        'Remaining:',
                        CurrencyFormatter.format(
                          (currentBudget - spent).clamp(0, double.infinity),
                          currency: currency,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isLoading || categoriesState.categories.isEmpty
                          ? null
                          : _saveBudget,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Save Budget',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
