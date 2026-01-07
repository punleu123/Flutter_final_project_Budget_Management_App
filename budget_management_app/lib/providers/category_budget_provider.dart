import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/hive_boxes.dart';
import '../models/category_budget_template.dart';
import '../models/monthly_category_budget.dart';

/// Category budget notifier for managing budget targets
class CategoryBudgetNotifier extends StateNotifier<CategoryBudgetState> {
  CategoryBudgetNotifier()
    : super(CategoryBudgetState(templates: [], monthlyOverrides: [])) {
    loadAllBudgets();
  }

  /// Load all budgets from Hive
  void loadAllBudgets() {
    final templates =
        HiveBoxes.categoryBudgetTemplateBox.values
            .cast<CategoryBudgetTemplate>()
            .toList();
    final overrides =
        HiveBoxes.monthlyCategoryBudgetBox.values
            .cast<MonthlyCategoryBudget>()
            .toList();

    state = CategoryBudgetState(
      templates: templates,
      monthlyOverrides: overrides,
    );
  }

  /// Get target for a category in a specific month
  /// Returns monthly override if exists, otherwise template
  double getTarget(String categoryId, int month, int year) {
    // Check for monthly override first
    final override = state.monthlyOverrides.firstWhere(
      (b) => b.categoryId == categoryId && b.month == month && b.year == year,
      orElse:
          () => MonthlyCategoryBudget(
            id: '',
            categoryId: '',
            month: 0,
            year: 0,
            targetAmount: 0,
            createdAt: DateTime.now(),
          ),
    );

    if (override.id.isNotEmpty) {
      return override.targetAmount;
    }

    // Fall back to template
    final template = state.templates.firstWhere(
      (t) => t.categoryId == categoryId,
      orElse:
          () => CategoryBudgetTemplate(
            id: '',
            categoryId: '',
            targetAmount: 0,
            createdAt: DateTime.now(),
          ),
    );

    return template.targetAmount;
  }

  /// Set template budget for a category
  Future<void> setTemplateBudget(String categoryId, double amount) async {
    // Check if template exists
    final existingIndex = state.templates.indexWhere(
      (t) => t.categoryId == categoryId,
    );

    final now = DateTime.now();
    final template = CategoryBudgetTemplate(
      id: 'template_$categoryId',
      categoryId: categoryId,
      targetAmount: amount,
      createdAt: now,
      updatedAt: now,
    );

    if (existingIndex != -1) {
      await HiveBoxes.categoryBudgetTemplateBox.putAt(existingIndex, template);
    } else {
      await HiveBoxes.categoryBudgetTemplateBox.add(template);
    }

    loadAllBudgets();
  }

  /// Set monthly override for a category
  Future<void> setMonthlyOverride(
    String categoryId,
    int month,
    int year,
    double amount,
  ) async {
    // Check if override exists
    final existingIndex = state.monthlyOverrides.indexWhere(
      (b) => b.categoryId == categoryId && b.month == month && b.year == year,
    );

    final now = DateTime.now();
    final override = MonthlyCategoryBudget(
      id: 'monthly_${categoryId}_${year}_${month.toString().padLeft(2, '0')}',
      categoryId: categoryId,
      month: month,
      year: year,
      targetAmount: amount,
      createdAt: now,
      updatedAt: now,
    );

    if (existingIndex != -1) {
      await HiveBoxes.monthlyCategoryBudgetBox.putAt(existingIndex, override);
    } else {
      await HiveBoxes.monthlyCategoryBudgetBox.add(override);
    }

    loadAllBudgets();
  }

  /// Delete monthly override (falls back to template)
  Future<void> deleteMonthlyOverride(
    String categoryId,
    int month,
    int year,
  ) async {
    final index = state.monthlyOverrides.indexWhere(
      (b) => b.categoryId == categoryId && b.month == month && b.year == year,
    );

    if (index != -1) {
      await HiveBoxes.monthlyCategoryBudgetBox.deleteAt(index);
      loadAllBudgets();
    }
  }

  /// Delete template budget
  Future<void> deleteTemplateBudget(String categoryId) async {
    final index = state.templates.indexWhere((t) => t.categoryId == categoryId);

    if (index != -1) {
      await HiveBoxes.categoryBudgetTemplateBox.deleteAt(index);
      loadAllBudgets();
    }
  }

  /// Get all categories with budgets
  List<String> getAllCategoriesWithBudgets() {
    final categories = <String>{};
    for (var template in state.templates) {
      categories.add(template.categoryId);
    }
    for (var override in state.monthlyOverrides) {
      categories.add(override.categoryId);
    }
    return categories.toList();
  }
}

/// Category budget state
class CategoryBudgetState {
  final List<CategoryBudgetTemplate> templates;
  final List<MonthlyCategoryBudget> monthlyOverrides;

  CategoryBudgetState({
    required this.templates,
    required this.monthlyOverrides,
  });

  /// Copy with modified fields
  CategoryBudgetState copyWith({
    List<CategoryBudgetTemplate>? templates,
    List<MonthlyCategoryBudget>? monthlyOverrides,
  }) {
    return CategoryBudgetState(
      templates: templates ?? this.templates,
      monthlyOverrides: monthlyOverrides ?? this.monthlyOverrides,
    );
  }
}

/// Provider for category budget
final categoryBudgetProvider =
    StateNotifierProvider<CategoryBudgetNotifier, CategoryBudgetState>((ref) {
      return CategoryBudgetNotifier();
    });

/// Provider to get target for a specific category and month
final categoryTargetProvider = Provider.family<double, (String, int, int)>((
  ref,
  param,
) {
  final categoryId = param.$1;
  final month = param.$2;
  final year = param.$3;
  return ref
      .watch(categoryBudgetProvider.notifier)
      .getTarget(categoryId, month, year);
});

/// Provider to get all categories with budgets
final categoriesWithBudgetsProvider = Provider<List<String>>((ref) {
  return ref
      .watch(categoryBudgetProvider.notifier)
      .getAllCategoriesWithBudgets();
});
