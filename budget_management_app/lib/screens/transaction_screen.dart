import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/budget_provider.dart';
import '../models/transaction_type.dart';
import '../core/currency_formatter.dart';
import 'add_transaction_screen.dart';

/// Transaction Screen - Shows transactions with filtering
class TransactionScreen extends ConsumerStatefulWidget {
  final DateTime selectedMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final String monthYear;
  final String currency;

  const TransactionScreen({
    Key? key,
    required this.selectedMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.monthYear,
    required this.currency,
  }) : super(key: key);

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  late String _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = 'All';
  }

  List<dynamic> _filterTransactions(List<dynamic> transactions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));

    switch (_selectedFilter) {
      case 'Daily':
        return transactions
            .where(
              (t) =>
                  DateTime(
                    t.transactionDate.year,
                    t.transactionDate.month,
                    t.transactionDate.day,
                  ) ==
                  today,
            )
            .toList();

      case 'Weekly':
        return transactions
            .where(
              (t) =>
                  t.transactionDate.isAfter(weekAgo) &&
                  t.transactionDate.isBefore(
                    today.add(const Duration(days: 1)),
                  ),
            )
            .toList();

      case 'Monthly':
        return transactions
            .where(
              (t) =>
                  t.transactionDate.month == widget.selectedMonth.month &&
                  t.transactionDate.year == widget.selectedMonth.year,
            )
            .toList();

      default:
        return transactions;
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(budgetProvider).allTransactions;
    final filteredTransactions = _filterTransactions(transactions);

    // Calculate totals
    double totalIncome = 0;
    double totalExpense = 0;

    for (var t in filteredTransactions) {
      if (t.type == TransactionType.income) {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
      }
    }

    final balance = totalIncome - totalExpense;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onPreviousMonth,
              ),
              Text(
                widget.monthYear,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: widget.onNextMonth,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Income',
                  totalIncome,
                  Colors.green,
                  Icons.add_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Expense',
                  totalExpense,
                  Colors.red,
                  Icons.remove_circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(
            'Balance',
            balance,
            balance >= 0 ? Colors.blue : Colors.orange,
            Icons.account_balance,
          ),
          const SizedBox(height: 24),

          // Filter Buttons
          Text(
            'Filter Transactions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children:
                ['All', 'Daily', 'Weekly', 'Monthly']
                    .map(
                      (filter) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: _selectedFilter == filter,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 24),

          // Transactions List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Transactions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddTransactionScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (filteredTransactions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'No transactions found',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children:
                  filteredTransactions
                      .map(
                        (transaction) => _buildTransactionTile(
                          context,
                          transaction,
                          widget.currency,
                        ),
                      )
                      .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(color: color, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.format(amount, currency: widget.currency),
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(
    BuildContext context,
    dynamic transaction,
    String currency,
  ) {
    final isIncome = transaction.type == TransactionType.income;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          isIncome ? Icons.add_circle : Icons.remove_circle,
          color: isIncome ? Colors.green : Colors.red,
        ),
        title: Text(transaction.description),
        subtitle: Text(
          transaction.transactionDate.toString().split(' ')[0],
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'} ${CurrencyFormatter.format(transaction.amount, currency: currency)}',
          style: TextStyle(
            color: isIncome ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
