import 'package:flutter/material.dart';
import '../core/currency_formatter.dart';

/// Category budget slider widget showing progress towards budget target
class CategoryBudgetSlider extends StatelessWidget {
  final String categoryName;
  final double spentAmount;
  final double targetAmount;
  final VoidCallback onEdit;
  final String? currencyCode;

  const CategoryBudgetSlider({
    Key? key,
    required this.categoryName,
    required this.spentAmount,
    required this.targetAmount,
    required this.onEdit,
    this.currencyCode,
  }) : super(key: key);

  Color _getProgressColor() {
    if (targetAmount <= 0) return Colors.grey;
    final percentage = (spentAmount / targetAmount) * 100;
    if (percentage < 80) return Colors.green;
    if (percentage < 100) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = targetAmount > 0 ? (spentAmount / targetAmount) : 0.0;
    final progressValue = percentage.clamp(0.0, 1.0);
    final progress = '${(progressValue * 100).toStringAsFixed(1)}%';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  categoryName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spent: ${CurrencyFormatter.format(spentAmount, currency: currencyCode ?? 'USD')}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  progress,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getProgressColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Budget: ${CurrencyFormatter.format(targetAmount, currency: currencyCode ?? 'USD')}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
