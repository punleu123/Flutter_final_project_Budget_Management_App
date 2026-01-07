import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

/// Screen for editing category budget targets
class EditCategoryBudgetScreen extends ConsumerStatefulWidget {
  const EditCategoryBudgetScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EditCategoryBudgetScreen> createState() =>
      _EditCategoryBudgetScreenState();
}

class _EditCategoryBudgetScreenState
    extends ConsumerState<EditCategoryBudgetScreen> {
  late TextEditingController _budgetController;
  late String _selectedCategory;
  late bool _applyToAllMonths;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _budgetController = TextEditingController();
    _selectedCategory = '1';
    _applyToAllMonths = true;
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _saveBudget() async {
    if (_budgetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a budget amount')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // final budget = double.parse(_budgetController.text);

      // In a real app, you would call:
      // if (_applyToAllMonths) {
      //   ref.read(categoryBudgetProvider.notifier)
      //       .setTemplateBudget(_selectedCategory, budget);
      // } else {
      //   ref.read(categoryBudgetProvider.notifier)
      //       .setMonthlyOverride(_selectedCategory, DateTime.now(), budget);
      // }

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

    final categories = [
      {'id': '1', 'name': 'Food & Dining'},
      {'id': '2', 'name': 'Transportation'},
      {'id': '3', 'name': 'Entertainment'},
      {'id': '4', 'name': 'Shopping'},
      {'id': '5', 'name': 'Utilities'},
      {'id': '6', 'name': 'Healthcare'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Budget'), elevation: 0),
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
                      DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        items:
                            categories
                                .map(
                                  (category) => DropdownMenuItem(
                                    value: category['id'] as String,
                                    child: Text(category['name'] as String),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value ?? '1';
                          });
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
                      _buildInfoRow('Category:', 'Food & Dining'),
                      _buildInfoRow('Current Budget:', '\$500.00'),
                      _buildInfoRow('Spent This Month:', '\$250.00'),
                      _buildInfoRow('Remaining:', '\$250.00'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveBudget,
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
