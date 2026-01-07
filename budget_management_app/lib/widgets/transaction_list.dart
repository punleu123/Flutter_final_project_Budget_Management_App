import 'package:flutter/material.dart';
import '../core/currency_formatter.dart';

/// Transaction list widget displaying all transactions
class TransactionList extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String? currencyCode;

  const TransactionList({
    Key? key,
    required this.transactions,
    this.onEdit,
    this.onDelete,
    this.currencyCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
              SizedBox(height: 16),
              Text(
                'No transactions yet',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isIncome = transaction['type'] == 'income';
        final amountColor = isIncome ? Colors.green : Colors.red;

        return Card(
          margin: EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Icon(
              isIncome ? Icons.add_circle : Icons.remove_circle,
              color: amountColor,
            ),
            title: Text(
              transaction['description'] ?? 'Transaction',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            subtitle: Text(
              '${transaction['category']} • ${transaction['date']}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Text(
              '${isIncome ? '+' : '-'}${CurrencyFormatter.format(transaction['amount'] as double, currency: currencyCode ?? 'USD')}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: amountColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
