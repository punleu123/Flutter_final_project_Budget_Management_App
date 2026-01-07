import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/currency_formatter.dart';
import '../providers/settings_provider.dart';
import '../providers/budget_provider.dart';
import '../models/transaction_type.dart';
import 'edit_category_budget_screen.dart';
import 'transaction_screen.dart';

/// Home screen with bottom navigation: Budget Targets and Transactions
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late DateTime _selectedMonth;
  int _currentTab = 0; // 0 = Budget Targets, 1 = Transactions

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  String _getMonthYear() {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[_selectedMonth.month - 1]} ${_selectedMonth.year}';
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(settingsProvider).currency;
    final transactions = ref.watch(budgetProvider).monthlyTransactions;

    // Calculate totals for selected month
    final monthTransactions =
        transactions
            .where(
              (t) =>
                  t.transactionDate.month == _selectedMonth.month &&
                  t.transactionDate.year == _selectedMonth.year,
            )
            .toList();

    double totalIncome = 0;
    double totalExpense = 0;

    for (var t in monthTransactions) {
      if (t.type == TransactionType.income) {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
      }
    }

    final balance = totalIncome - totalExpense;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      // Clean AppBar with centered currency toggle
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currency,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 12),
            Switch(
              value: currency == 'KHR',
              onChanged: (value) {
                ref.read(settingsProvider.notifier).toggleCurrency();
              },
              activeColor: Colors.green,
              inactiveThumbColor: Colors.blue,
            ),
          ],
        ),
      ),
      // Body: Show content based on selected tab
      body:
          _currentTab == 0
              ? _buildBudgetTab(
                context,
                currency,
                totalIncome,
                totalExpense,
                balance,
              )
              : TransactionScreen(
                selectedMonth: _selectedMonth,
                onPreviousMonth: _previousMonth,
                onNextMonth: _nextMonth,
                monthYear: _getMonthYear(),
                currency: currency,
              ),
      // Bottom Navigation Bar instead of TabBar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) {
          setState(() {
            _currentTab = index;
          });
        },
        backgroundColor: Colors.white,
        elevation: 8,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[400],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet_outlined),
            activeIcon: Icon(Icons.wallet),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_outlined),
            activeIcon: Icon(Icons.receipt),
            label: 'Transactions',
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetTab(
    BuildContext context,
    String currency,
    double totalIncome,
    double totalExpense,
    double balance,
  ) {
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
                onPressed: _previousMonth,
              ),
              Text(
                _getMonthYear(),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.blue),
                onPressed: _nextMonth,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Summary Cards - Clean design without borders
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Income',
                  totalIncome,
                  Colors.green,
                  Icons.add_circle,
                  currency,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Expense',
                  totalExpense,
                  Colors.red,
                  Icons.remove_circle,
                  currency,
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
            currency,
          ),
          const SizedBox(height: 28),

          // Category Budgets Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Category Budgets',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              FloatingActionButton.small(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const EditCategoryBudgetScreen(),
                    ),
                  );
                },
                backgroundColor: Colors.blue,
                child: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category Budget Sliders
          _buildCategoryBudgetSliders(context, currency),
        ],
      ),
    );
  }

  Widget _buildCategoryBudgetSliders(BuildContext context, String currency) {
    final categories = [
      {'id': 'food', 'name': 'Food & Dining', 'icon': '🍔'},
      {'id': 'transport', 'name': 'Transportation', 'icon': '🚗'},
      {'id': 'entertainment', 'name': 'Entertainment', 'icon': '🎬'},
      {'id': 'shopping', 'name': 'Shopping', 'icon': '🛍️'},
      {'id': 'utilities', 'name': 'Utilities', 'icon': '💡'},
      {'id': 'healthcare', 'name': 'Healthcare', 'icon': '🏥'},
    ];

    return Column(
      children:
          categories
              .map(
                (cat) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildCategoryBudgetSlider(
                    categoryName: cat['name']!,
                    categoryIcon: cat['icon']!,
                    spent: 250.0,
                    target: 500.0,
                    currency: currency,
                    onEditPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => const EditCategoryBudgetScreen(),
                        ),
                      );
                    },
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildCategoryBudgetSlider({
    required String categoryName,
    required String categoryIcon,
    required double spent,
    required double target,
    required String currency,
    required VoidCallback onEditPressed,
  }) {
    final percentage = spent / target;
    final isOverBudget = percentage > 1.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(categoryIcon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${CurrencyFormatter.format(spent, currency: currency)} / ${CurrencyFormatter.format(target, currency: currency)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                onPressed: onEditPressed,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: isOverBudget ? 1.0 : percentage,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? Colors.red : Colors.green,
              ),
            ),
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
    String currency,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(amount, currency: currency),
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
