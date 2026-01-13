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
  late DateTime _selectedWeekStart; // Track the start of selected week
  late DateTime _selectedDay; // Track the selected day for daily filter

  @override
  void initState() {
    super.initState();
    _selectedFilter = 'Monthly'; // Default to Monthly filter
    _selectedWeekStart = _getWeekStart(widget.selectedMonth);
    _selectedDay = DateTime(
      widget.selectedMonth.year,
      widget.selectedMonth.month,
      widget.selectedMonth.day,
    );
  }

  @override
  void didUpdateWidget(TransactionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update internal state when parent month changes
    if (oldWidget.selectedMonth != widget.selectedMonth) {
      setState(() {
        // Update week and day to match the new selected month
        _selectedWeekStart = _getWeekStart(widget.selectedMonth);
        _selectedDay = DateTime(
          widget.selectedMonth.year,
          widget.selectedMonth.month,
          1, // First day of the month
        );
      });
    }
  }

  /// Get the Monday of the week containing the given date
  DateTime _getWeekStart(DateTime date) {
    final weekDay = date.weekday;
    final daysToSubtract = weekDay - 1; // Monday is 1
    return DateTime(date.year, date.month, date.day - daysToSubtract);
  }

  /// Get the Sunday of the week containing the given date
  DateTime _getWeekEnd(DateTime date) {
    return _getWeekStart(date).add(const Duration(days: 6));
  }

  void _previousWeek() {
    setState(() {
      _selectedWeekStart = _selectedWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _selectedWeekStart = _selectedWeekStart.add(const Duration(days: 7));
    });
  }

  String _getWeekRange() {
    final weekEnd = _getWeekEnd(_selectedWeekStart);
    final monthsMap = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final startMonth = monthsMap[_selectedWeekStart.month - 1];
    final endMonth = monthsMap[weekEnd.month - 1];

    if (_selectedWeekStart.month == weekEnd.month) {
      return '${_selectedWeekStart.day} - ${weekEnd.day} $startMonth';
    } else {
      return '${_selectedWeekStart.day} $startMonth - ${weekEnd.day} $endMonth';
    }
  }

  void _previousDay() {
    setState(() {
      _selectedDay = _selectedDay.subtract(const Duration(days: 1));
    });
  }

  void _nextDay() {
    setState(() {
      _selectedDay = _selectedDay.add(const Duration(days: 1));
    });
  }

  String _getDayFormatted() {
    final monthsMap = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final daysMap = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return '${daysMap[_selectedDay.weekday - 1]} ${_selectedDay.day} ${monthsMap[_selectedDay.month - 1]}';
  }

  List<dynamic> _filterTransactions(List<dynamic> transactions) {
    final weekEnd = _getWeekEnd(_selectedWeekStart);

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
                  _selectedDay,
            )
            .toList();

      case 'Weekly':
        return transactions
            .where(
              (t) =>
                  t.transactionDate.isAfter(
                    _selectedWeekStart.subtract(const Duration(seconds: 1)),
                  ) &&
                  t.transactionDate.isBefore(
                    weekEnd.add(const Duration(days: 1)),
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
                icon: const Icon(Icons.arrow_back, color: Colors.blue),
                onPressed: widget.onPreviousMonth,
              ),
              Text(
                widget.monthYear,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.blue),
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
          const SizedBox(height: 16),

          // Day Navigation (only show when Daily filter is selected)
          if (_selectedFilter == 'Daily')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.blue),
                  onPressed: _previousDay,
                ),
                Text(
                  _getDayFormatted(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.blue),
                  onPressed: _nextDay,
                ),
              ],
            ),

          // Week Navigation (only show when Weekly filter is selected)
          if (_selectedFilter == 'Weekly')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.blue),
                  onPressed: _previousWeek,
                ),
                Text(
                  _getWeekRange(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.blue),
                  onPressed: _nextWeek,
                ),
              ],
            ),

          // Month Navigation (synchronized with HomeScreen)
          if (_selectedFilter == 'Monthly')
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Showing ${widget.monthYear} transactions',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
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
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddTransactionScreen(),
                    ),
                  );
                  // Refresh the screen after returning
                  if (mounted) {
                    setState(() {});
                  }
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
