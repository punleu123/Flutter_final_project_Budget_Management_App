import 'package:flutter/material.dart';
import '../core/currency_formatter.dart';

/// Summary card displaying income, expense, or balance
class SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final String? currencyCode;

  const SummaryCard({
    Key? key,
    required this.title,
    required this.amount,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    this.currencyCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: textColor, size: 24),
                SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              CurrencyFormatter.format(amount, currency: currencyCode ?? 'USD'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
