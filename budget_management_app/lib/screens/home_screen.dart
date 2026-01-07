import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/currency_formatter.dart';
import '../providers/settings_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/category_budget_provider.dart';
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

    // Watch the entire budget provider to get real-time updates
    ref.watch(budgetProvider);

    // Use reactive providers for real-time month calculations
    final totalIncome = ref.watch(
      monthlyIncomeTotalProvider((_selectedMonth.month, _selectedMonth.year)),
    );
    final totalExpense = ref.watch(
      monthlyExpenseProvider((_selectedMonth.month, _selectedMonth.year)),
    );
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
                (cat) => _buildCategorySliderWithWatcher(
                  context,
                  categoryId: cat['id']!,
                  categoryName: cat['name']!,
                  categoryIcon: cat['icon']!,
                  currency: currency,
                ),
              )
              .toList(),
    );
  }

  Widget _buildCategorySliderWithWatcher(
    BuildContext context, {
    required String categoryId,
    required String categoryName,
    required String categoryIcon,
    required String currency,
  }) {
    return Consumer(
      builder: (context, ref, child) {
        // Watch real-time spending data for this category
        final spent = ref.watch(
          categorySpendingProvider((
            categoryId,
            _selectedMonth.month,
            _selectedMonth.year,
          )),
        );

        // Watch budget target for this category
        final categoryBudgetNotifier = ref.watch(
          categoryBudgetProvider.notifier,
        );
        final target = categoryBudgetNotifier.getTarget(
          categoryId,
          _selectedMonth.month,
          _selectedMonth.year,
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildCategoryBudgetSlider(
            categoryName: categoryName,
            categoryIcon: categoryIcon,
            spent: spent,
            target: target,
            currency: currency,
            onEditPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EditCategoryBudgetScreen(),
                ),
              );
            },
          ),
        );
      },
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
    // Handle division by zero: if no target set, show 0% progress
    final percentage = target > 0 ? (spent / target).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = target > 0 && spent > target;

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
