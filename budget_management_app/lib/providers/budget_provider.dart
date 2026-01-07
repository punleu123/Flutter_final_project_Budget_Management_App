import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/hive_boxes.dart';
import '../models/transaction_model.dart';
import '../models/transaction_type.dart';

/// Budget notifier for managing transactions and calculations
class BudgetNotifier extends StateNotifier<BudgetState> {
  BudgetNotifier()
    : super(
        BudgetState(
          allTransactions: [],
          dailyTransactions: [],
          weeklyTransactions: [],
          monthlyTransactions: [],
        ),
      ) {
    loadTransactions();
  }

  /// Load all transactions from Hive
  void loadTransactions() {
    final transactions =
        HiveBoxes.transactionsBox.values.cast<TransactionModel>().toList();
    state = state.copyWith(allTransactions: transactions);
    _filterByPeriod();
  }

  /// Filter transactions by period (daily, weekly, monthly)
  void _filterByPeriod() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(Duration(days: 7));
    final monthStart = DateTime(now.year, now.month, 1);

    final daily =
        state.allTransactions
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

    final weekly =
        state.allTransactions
            .where(
              (t) =>
                  t.transactionDate.isAfter(weekAgo) &&
                  t.transactionDate.isBefore(today.add(Duration(days: 1))),
            )
            .toList();

    final monthly =
        state.allTransactions
            .where(
              (t) =>
                  t.transactionDate.isAfter(monthStart) &&
                  t.transactionDate.isBefore(
                    monthStart.add(Duration(days: 31)),
                  ),
            ) // Safe for all months
            .toList();

    state = state.copyWith(
      dailyTransactions: daily,
      weeklyTransactions: weekly,
      monthlyTransactions: monthly,
    );
  }

  /// Add a new transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    await HiveBoxes.transactionsBox.add(transaction);
    loadTransactions();
  }

  /// Update an existing transaction
  Future<void> updateTransaction(
    int index,
    TransactionModel transaction,
  ) async {
    await HiveBoxes.transactionsBox.putAt(index, transaction);
    loadTransactions();
  }

  /// Delete a transaction
  Future<void> deleteTransaction(int index) async {
    await HiveBoxes.transactionsBox.deleteAt(index);
    loadTransactions();
  }

  /// Get transactions for a specific day
  List<TransactionModel> getTransactionsForDay(DateTime date) {
    final targetDay = DateTime(date.year, date.month, date.day);
    return state.allTransactions
        .where(
          (t) =>
              DateTime(
                t.transactionDate.year,
                t.transactionDate.month,
                t.transactionDate.day,
              ) ==
              targetDay,
        )
        .toList();
  }

  /// Get transactions for a specific month
  List<TransactionModel> getTransactionsForMonth(int month, int year) {
    return state.allTransactions
        .where(
          (t) =>
              t.transactionDate.month == month &&
              t.transactionDate.year == year,
        )
        .toList();
  }

  /// Calculate total income for specific month
  double getTotalIncomeForMonth(int month, int year) {
    return state.allTransactions
        .where(
          (t) =>
              t.type == TransactionType.income &&
              t.transactionDate.month == month &&
              t.transactionDate.year == year,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculate total expense for specific month
  double getTotalExpenseForMonth(int month, int year) {
    return state.allTransactions
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.transactionDate.month == month &&
              t.transactionDate.year == year,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculate balance for specific month
  double getBalanceForMonth(int month, int year) {
    final income = getTotalIncomeForMonth(month, year);
    final expense = getTotalExpenseForMonth(month, year);
    return income - expense;
  }

  /// Calculate total income
  double get totalIncome {
    return state.monthlyTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculate total expense
  double get totalExpense {
    return state.monthlyTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculate balance (income - expense)
  double get balance => totalIncome - totalExpense;

  /// Get monthly total for specific category
  double getMonthlyTotalForCategory(String categoryId, int month, int year) {
    return state.allTransactions
        .where(
          (t) =>
              t.categoryId == categoryId &&
              t.transactionDate.month == month &&
              t.transactionDate.year == year &&
              t.type == TransactionType.expense,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Get monthly total for all expenses
  double getMonthlyExpenseTotal(int month, int year) {
    return state.allTransactions
        .where(
          (t) =>
              t.transactionDate.month == month &&
              t.transactionDate.year == year &&
              t.type == TransactionType.expense,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}

/// Budget state
class BudgetState {
  final List<TransactionModel> allTransactions;
  final List<TransactionModel> dailyTransactions;
  final List<TransactionModel> weeklyTransactions;
  final List<TransactionModel> monthlyTransactions;

  BudgetState({
    required this.allTransactions,
    required this.dailyTransactions,
    required this.weeklyTransactions,
    required this.monthlyTransactions,
  });

  /// Copy with modified fields
  BudgetState copyWith({
    List<TransactionModel>? allTransactions,
    List<TransactionModel>? dailyTransactions,
    List<TransactionModel>? weeklyTransactions,
    List<TransactionModel>? monthlyTransactions,
  }) {
    return BudgetState(
      allTransactions: allTransactions ?? this.allTransactions,
      dailyTransactions: dailyTransactions ?? this.dailyTransactions,
      weeklyTransactions: weeklyTransactions ?? this.weeklyTransactions,
      monthlyTransactions: monthlyTransactions ?? this.monthlyTransactions,
    );
  }
}

/// Provider for budget
final budgetProvider = StateNotifierProvider<BudgetNotifier, BudgetState>((
  ref,
) {
  return BudgetNotifier();
});

/// Provider for total income
final totalIncomeProvider = Provider<double>((ref) {
  return ref.watch(budgetProvider.notifier).totalIncome;
});

/// Provider for total expense
final totalExpenseProvider = Provider<double>((ref) {
  return ref.watch(budgetProvider.notifier).totalExpense;
});

/// Provider for balance
final balanceProvider = Provider<double>((ref) {
  return ref.watch(budgetProvider.notifier).balance;
});

/// Provider to get transactions for specific month
final monthlyTransactionsProvider =
    FutureProvider.family<List<TransactionModel>, (int, int)>((ref, param) {
      final month = param.$1;
      final year = param.$2;
      return Future.value(
        ref.watch(budgetProvider.notifier).getTransactionsForMonth(month, year),
      );
    });

/// Provider to get monthly total for category
final monthlyTotalForCategoryProvider =
    Provider.family<double, (String, int, int)>((ref, param) {
      final categoryId = param.$1;
      final month = param.$2;
      final year = param.$3;
      return ref
          .watch(budgetProvider.notifier)
          .getMonthlyTotalForCategory(categoryId, month, year);
    });

/// Provider to get monthly expense total
final monthlyExpenseTotalProvider = Provider.family<double, (int, int)>((
  ref,
  param,
) {
  final month = param.$1;
  final year = param.$2;
  return ref.watch(budgetProvider.notifier).getMonthlyExpenseTotal(month, year);
});

/// Provider for monthly income (real-time with month parameter)
final monthlyIncomeTotalProvider = Provider.family<double, (int, int)>((
  ref,
  param,
) {
  final month = param.$1;
  final year = param.$2;
  return ref.watch(budgetProvider.notifier).getTotalIncomeForMonth(month, year);
});

/// Provider for monthly expense (real-time with month parameter)
final monthlyExpenseProvider = Provider.family<double, (int, int)>((
  ref,
  param,
) {
  final month = param.$1;
  final year = param.$2;
  return ref
      .watch(budgetProvider.notifier)
      .getTotalExpenseForMonth(month, year);
});

/// Provider for monthly balance (real-time with month parameter)
final monthlyBalanceProvider = Provider.family<double, (int, int)>((
  ref,
  param,
) {
  final month = param.$1;
  final year = param.$2;
  return ref.watch(budgetProvider.notifier).getBalanceForMonth(month, year);
});

/// Provider for category spending (real-time with month parameter)
final categorySpendingProvider = Provider.family<double, (String, int, int)>((
  ref,
  param,
) {
  final categoryId = param.$1;
  final month = param.$2;
  final year = param.$3;
  return ref
      .watch(budgetProvider.notifier)
      .getMonthlyTotalForCategory(categoryId, month, year);
});

/// Provider for transactions filtered by month (real-time)
final monthTransactionsProvider =
    Provider.family<List<TransactionModel>, (int, int)>((ref, param) {
      final month = param.$1;
      final year = param.$2;
      final allTransactions = ref.watch(budgetProvider).allTransactions;
      return allTransactions
          .where(
            (t) =>
                t.transactionDate.month == month &&
                t.transactionDate.year == year,
          )
          .toList();
    });
