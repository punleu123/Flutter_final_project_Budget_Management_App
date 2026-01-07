import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/hive_boxes.dart';
import '../models/budget.dart';

/// Budget notifier for CRUD operations on budgets
class BudgetManagementNotifier extends StateNotifier<BudgetManagementState> {
  BudgetManagementNotifier() : super(BudgetManagementState(budgets: [])) {
    loadBudgets();
  }

  /// Load all budgets from Hive
  void loadBudgets() {
    final budgets = HiveBoxes.budgetsBox.values.cast<Budget>().toList();
    state = BudgetManagementState(budgets: budgets);
  }

  /// Create a new budget
  Future<void> createBudget(Budget budget) async {
    try {
      await HiveBoxes.budgetsBox.add(budget);
      loadBudgets();
    } catch (e) {
      rethrow;
    }
  }

  /// Get budget by ID
  Budget? getBudgetById(String id) {
    try {
      return state.budgets.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Update an existing budget
  Future<void> updateBudget(int index, Budget budget) async {
    try {
      await HiveBoxes.budgetsBox.putAt(index, budget);
      loadBudgets();
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a budget
  Future<void> deleteBudget(int index) async {
    try {
      await HiveBoxes.budgetsBox.deleteAt(index);
      loadBudgets();
    } catch (e) {
      rethrow;
    }
  }

  /// Delete budget by ID
  Future<void> deleteBudgetById(String id) async {
    try {
      final index = state.budgets.indexWhere((b) => b.id == id);
      if (index != -1) {
        await HiveBoxes.budgetsBox.deleteAt(index);
        loadBudgets();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get all budgets
  List<Budget> getAllBudgets() => state.budgets;

  /// Get budgets for specific user
  List<Budget> getBudgetsForUser(String userId) {
    return state.budgets.where((b) => b.userId == userId).toList();
  }

  /// Get budget count
  int getBudgetCount() => state.budgets.length;

  /// Check if budget exists
  bool budgetExists(String id) {
    return state.budgets.any((b) => b.id == id);
  }

  /// Get total allocated budget
  double getTotalAllocatedBudget() {
    return state.budgets.fold(0.0, (sum, b) => sum + b.limitAmount);
  }

  /// Get total spent amount from transactions
  double getTotalSpent() {
    // Note: This would require accessing transactionsBox
    // For now, return 0 or implement via transaction calculation
    return 0.0;
  }

  /// Get remaining budget
  double getRemainingBudget() {
    return getTotalAllocatedBudget() - getTotalSpent();
  }

  /// Get budget by month and year
  List<Budget> getBudgetsByMonth(int month, int year) {
    return state.budgets
        .where((b) => b.createdAt.month == month && b.createdAt.year == year)
        .toList();
  }
}

/// Budget management state
class BudgetManagementState {
  final List<Budget> budgets;

  BudgetManagementState({required this.budgets});

  /// Copy with modified fields
  BudgetManagementState copyWith({List<Budget>? budgets}) {
    return BudgetManagementState(budgets: budgets ?? this.budgets);
  }
}

/// Provider for budget management
final budgetManagementProvider =
    StateNotifierProvider<BudgetManagementNotifier, BudgetManagementState>(
      (ref) => BudgetManagementNotifier(),
    );

/// Provider to get all budgets
final allBudgetsProvider = Provider<List<Budget>>((ref) {
  return ref.watch(budgetManagementProvider).budgets;
});

/// Provider to get budget by ID
final budgetByIdProvider = Provider.family<Budget?, String>((ref, id) {
  return ref.watch(budgetManagementProvider.notifier).getBudgetById(id);
});

/// Provider to get budgets for specific user
final userBudgetsProvider = Provider.family<List<Budget>, String>((
  ref,
  userId,
) {
  return ref.watch(budgetManagementProvider.notifier).getBudgetsForUser(userId);
});

/// Provider to get budget count
final budgetCountProvider = Provider<int>((ref) {
  return ref.watch(budgetManagementProvider).budgets.length;
});

/// Provider to get total allocated budget
final totalAllocatedBudgetProvider = Provider<double>((ref) {
  return ref.watch(budgetManagementProvider.notifier).getTotalAllocatedBudget();
});

/// Provider to get total spent
final totalSpentProvider = Provider<double>((ref) {
  return ref.watch(budgetManagementProvider.notifier).getTotalSpent();
});

/// Provider to get remaining budget
final remainingBudgetProvider = Provider<double>((ref) {
  return ref.watch(budgetManagementProvider.notifier).getRemainingBudget();
});

/// Provider to get budgets by month
final budgetsByMonthProvider = Provider.family<List<Budget>, (int, int)>((
  ref,
  param,
) {
  final month = param.$1;
  final year = param.$2;
  return ref
      .watch(budgetManagementProvider.notifier)
      .getBudgetsByMonth(month, year);
});
