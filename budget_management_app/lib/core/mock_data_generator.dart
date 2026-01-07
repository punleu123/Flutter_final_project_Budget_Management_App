import 'package:flutter/foundation.dart';
import '../core/hive_boxes.dart';
import '../models/transaction_model.dart';
import '../models/category.dart' as models;
import '../models/category_budget_template.dart';
import '../models/transaction_type.dart';

/// Mock data generator for testing
class MockDataGenerator {
  /// Generate two months of test data (December & January)
  static Future<void> generateTestData() async {
    if (!kDebugMode) return; // Only in debug mode

    // Clear existing data
    await clearTestData();

    // Create categories
    await _createCategories();

    // Create budget templates
    await _createBudgetTemplates();

    // Create transactions for December 2025
    await _createDecemberTransactions();

    // Create transactions for January 2026
    await _createJanuaryTransactions();

    debugPrint('✅ Mock data generated successfully');
  }

  /// Clear all test data
  static Future<void> clearTestData() async {
    await HiveBoxes.transactionsBox.clear();
    await HiveBoxes.categoriesBox.clear();
    await HiveBoxes.categoryBudgetTemplateBox.clear();
    debugPrint('✅ Test data cleared');
  }

  /// Create sample categories
  static Future<void> _createCategories() async {
    final categories = [
      models.Category(
        id: 'food',
        name: 'Food & Dining',
        icon: '🍔',
        color: 'FF6B6B',
        createdAt: DateTime.now(),
      ),
      models.Category(
        id: 'transport',
        name: 'Transportation',
        icon: '🚗',
        color: '4ECDC4',
        createdAt: DateTime.now(),
      ),
      models.Category(
        id: 'entertainment',
        name: 'Entertainment',
        icon: '🎬',
        color: '45B7D1',
        createdAt: DateTime.now(),
      ),
      models.Category(
        id: 'shopping',
        name: 'Shopping',
        icon: '🛍️',
        color: 'FFA07A',
        createdAt: DateTime.now(),
      ),
      models.Category(
        id: 'utilities',
        name: 'Utilities',
        icon: '💡',
        color: '95E1D3',
        createdAt: DateTime.now(),
      ),
      models.Category(
        id: 'healthcare',
        name: 'Healthcare',
        icon: '🏥',
        color: 'C7CEEA',
        createdAt: DateTime.now(),
      ),
    ];

    for (final category in categories) {
      await HiveBoxes.categoriesBox.add(category);
    }
  }

  /// Create budget templates
  static Future<void> _createBudgetTemplates() async {
    final templates = [
      CategoryBudgetTemplate(
        id: 'template_food',
        categoryId: 'food',
        targetAmount: 500.0,
        createdAt: DateTime.now(),
      ),
      CategoryBudgetTemplate(
        id: 'template_transport',
        categoryId: 'transport',
        targetAmount: 200.0,
        createdAt: DateTime.now(),
      ),
      CategoryBudgetTemplate(
        id: 'template_entertainment',
        categoryId: 'entertainment',
        targetAmount: 150.0,
        createdAt: DateTime.now(),
      ),
      CategoryBudgetTemplate(
        id: 'template_shopping',
        categoryId: 'shopping',
        targetAmount: 300.0,
        createdAt: DateTime.now(),
      ),
      CategoryBudgetTemplate(
        id: 'template_utilities',
        categoryId: 'utilities',
        targetAmount: 150.0,
        createdAt: DateTime.now(),
      ),
      CategoryBudgetTemplate(
        id: 'template_healthcare',
        categoryId: 'healthcare',
        targetAmount: 100.0,
        createdAt: DateTime.now(),
      ),
    ];

    for (final template in templates) {
      await HiveBoxes.categoryBudgetTemplateBox.add(template);
    }
  }

  /// Create December 2025 transactions
  static Future<void> _createDecemberTransactions() async {
    final transactions = [
      // DECEMBER INCOME
      TransactionModel(
        id: 'trans_dec_income_1',
        budgetId: 'budget_1',
        categoryId: 'food',
        description: 'Salary',
        amount: 2500.0,
        type: TransactionType.income,
        transactionDate: DateTime(2025, 12, 1),
        createdAt: DateTime(2025, 12, 1),
      ),
      TransactionModel(
        id: 'trans_dec_income_2',
        budgetId: 'budget_1',
        categoryId: 'shopping',
        description: 'Freelance Project',
        amount: 500.0,
        type: TransactionType.income,
        transactionDate: DateTime(2025, 12, 15),
        createdAt: DateTime(2025, 12, 15),
      ),

      // DECEMBER EXPENSES - Food
      TransactionModel(
        id: 'trans_dec_food_1',
        budgetId: 'budget_1',
        categoryId: 'food',
        description: 'Grocery Shopping',
        amount: 85.50,
        type: TransactionType.expense,
        transactionDate: DateTime(2025, 12, 2),
        createdAt: DateTime(2025, 12, 2),
      ),
      TransactionModel(
        id: 'trans_dec_food_2',
        budgetId: 'budget_1',
        categoryId: 'food',
        description: 'Restaurant Dinner',
        amount: 45.00,
        type: TransactionType.expense,
        transactionDate: DateTime(2025, 12, 5),
        createdAt: DateTime(2025, 12, 5),
      ),
      TransactionModel(
        id: 'trans_dec_food_3',
        budgetId: 'budget_1',
        categoryId: 'food',
        description: 'Coffee Shop',
        amount: 5.50,
        type: TransactionType.expense,
        transactionDate: DateTime(2025, 12, 8),
        createdAt: DateTime(2025, 12, 8),
      ),
      TransactionModel(
        id: 'trans_dec_food_4',
        budgetId: 'budget_1',
        categoryId: 'food',
        description: 'Lunch at Cafe',
        amount: 12.00,
        type: TransactionType.expense,
        transactionDate: DateTime(2025, 12, 12),
        createdAt: DateTime(2025, 12, 12),
      ),
      TransactionModel(
        id: 'trans_dec_food_5',
        budgetId: 'budget_1',
        categoryId: 'food',
        description: 'Holiday Dinner',
        amount: 120.00,
        type: TransactionType.expense,
        transactionDate: DateTime(2025, 12, 24),
        createdAt: DateTime(2025, 12, 24),
      ),

      // DECEMBER EXPENSES - Transportation
      TransactionModel(
        id: 'trans_dec_trans_1',
        budgetId: 'budget_1',
        categoryId: 'transport',
        description: 'Gas Station',
        amount: 60.00,
        type: TransactionType.expense,
        transactionDate: DateTime(2025, 12, 3),
        createdAt: DateTime(2025, 12, 3),
      ),
      TransactionModel(
        id: 'trans_dec_trans_2',
        budgetId: 'budget_1',
        categoryId: 'transport',
        description: 'Car Maintenance',
        amount: 85.00,
        type: TransactionType.expense,
        transactionDate: DateTime(2025, 12, 10),
        createdAt: DateTime(2025, 12, 10),
      ),

      // DECEMBER EXPENSES - Entertainment
      TransactionModel(
        id: 'trans_dec_ent_1',
        budgetId: 'budget_1',
        categoryId: 'entertainment',
        description: 'Movie Tickets',
        amount: 30.00,
        type: TransactionType.expense,
        transactionDate: DateTime(2025, 12, 7),
        createdAt: DateTime(2025, 12, 7),
      ),
      TransactionModel(
        id: 'trans_dec_ent_2',
        budgetId: 'budget_1',
        categoryId: 'entertainment',
        description: 'Concert Tickets',
        amount: 75.00,
        type: TransactionType.expense,
        transactionDate: DateTime(2025, 12, 20),
        createdAt: DateTime(2025, 12, 20),
      ),

      // DECEMBER EXPENSES - Shopping
      TransactionModel(
        id: 'trans_dec_shop_1',
        budgetId: 'budget_1',
        categoryId: 'shopping',
        description: 'Winter Clothes',
        amount: 150.00,
        type: TransactionType.expense,
        transactionDate: DateTime(2025, 12, 6),
        createdAt: DateTime(2025, 12, 6),
      ),
      TransactionModel(
        id: 'trans_dec_shop_2',
        budgetId: 'budget_1',
        categoryId: 'shopping',
        description: 'Gift Shopping',
        amount: 200.00,
        type: TransactionType.expense,
        transactionDate: DateTime(2025, 12, 18),
        createdAt: DateTime(2025, 12, 18),
      ),

      // DECEMBER EXPENSES - Utilities
      TransactionModel(
        id: 'trans_dec_util_1',
        budgetId: 'budget_1',
        categoryId: 'utilities',
        description: 'Electricity Bill',
        amount: 80.00,
        type: TransactionType.expense,
        transactionDate: DateTime(2025, 12, 1),
        createdAt: DateTime(2025, 12, 1),
      ),
      TransactionModel(
        id: 'trans_dec_util_2',
        budgetId: 'budget_1',
        categoryId: 'utilities',
        description: 'Internet Bill',
        amount: 60.00,
        type: TransactionType.expense,
        transactionDate: DateTime(2025, 12, 1),
        createdAt: DateTime(2025, 12, 1),
      ),

      // DECEMBER EXPENSES - Healthcare
      TransactionModel(
        id: 'trans_dec_health_1',
        budgetId: 'budget_1',
        categoryId: 'healthcare',
        description: 'Doctor Visit',
        amount: 75.00,
        type: TransactionType.expense,
        transactionDate: DateTime(2025, 12, 15),
        createdAt: DateTime(2025, 12, 15),
      ),
    ];

    for (final transaction in transactions) {
      await HiveBoxes.transactionsBox.add(transaction);
    }

    debugPrint('✅ December transactions created: ${transactions.length}');
  }

  /// Create January 2026 transactions
  static Future<void> _createJanuaryTransactions() async {
    final transactions = [
      // JANUARY INCOME
      TransactionModel(
        id: 'trans_jan_income_1',
        budgetId: 'budget_1',
        categoryId: 'food',
        description: 'Salary',
        amount: 2500.0,
        type: TransactionType.income,
        transactionDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
      ),
      TransactionModel(
        id: 'trans_jan_income_2',
        budgetId: 'budget_1',
        categoryId: 'shopping',
        description: 'Bonus',
        amount: 300.0,
        type: TransactionType.income,
        transactionDate: DateTime(2026, 1, 10),
        createdAt: DateTime(2026, 1, 10),
      ),

      // JANUARY EXPENSES - Food
      TransactionModel(
        id: 'trans_jan_food_1',
        budgetId: 'budget_1',
        categoryId: 'food',
        description: 'Grocery Shopping',
        amount: 95.00,
        type: TransactionType.expense,
        transactionDate: DateTime(2026, 1, 2),
        createdAt: DateTime(2026, 1, 2),
      ),
      TransactionModel(
        id: 'trans_jan_food_2',
        budgetId: 'budget_1',
        categoryId: 'food',
        description: 'Restaurant Lunch',
        amount: 35.00,
        type: TransactionType.expense,
        transactionDate: DateTime(2026, 1, 5),
        createdAt: DateTime(2026, 1, 5),
      ),
      TransactionModel(
        id: 'trans_jan_food_3',
        budgetId: 'budget_1',
        categoryId: 'food',
        description: 'Coffee & Snacks',
        amount: 18.50,
        type: TransactionType.expense,
        transactionDate: DateTime(2026, 1, 8),
        createdAt: DateTime(2026, 1, 8),
      ),
      TransactionModel(
        id: 'trans_jan_food_4',
        budgetId: 'budget_1',
        categoryId: 'food',
        description: 'Supermarket',
        amount: 110.00,
        type: TransactionType.expense,
        transactionDate: DateTime(2026, 1, 14),
        createdAt: DateTime(2026, 1, 14),
      ),
      TransactionModel(
        id: 'trans_jan_food_5',
        budgetId: 'budget_1',
        categoryId: 'food',
        description: 'Pizza Night',
        amount: 28.00,
        type: TransactionType.expense,
        transactionDate: DateTime(2026, 1, 20),
        createdAt: DateTime(2026, 1, 20),
      ),

      // JANUARY EXPENSES - Transportation
      TransactionModel(
        id: 'trans_jan_trans_1',
        budgetId: 'budget_1',
        categoryId: 'transport',
        description: 'Gas Station',
        amount: 55.00,
        type: TransactionType.expense,
        transactionDate: DateTime(2026, 1, 4),
        createdAt: DateTime(2026, 1, 4),
      ),
      TransactionModel(
        id: 'trans_jan_trans_2',
        budgetId: 'budget_1',
        categoryId: 'transport',
        description: 'Uber Ride',
        amount: 22.50,
        type: TransactionType.expense,
        transactionDate: DateTime(2026, 1, 12),
        createdAt: DateTime(2026, 1, 12),
      ),
      TransactionModel(
        id: 'trans_jan_trans_3',
        budgetId: 'budget_1',
        categoryId: 'transport',
        description: 'Parking Fee',
        amount: 10.00,
        type: TransactionType.expense,
        transactionDate: DateTime(2026, 1, 18),
        createdAt: DateTime(2026, 1, 18),
      ),

      // JANUARY EXPENSES - Entertainment
      TransactionModel(
        id: 'trans_jan_ent_1',
        budgetId: 'budget_1',
        categoryId: 'entertainment',
        description: 'Streaming Subscription',
        amount: 15.99,
        type: TransactionType.expense,
        transactionDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
      ),
      TransactionModel(
        id: 'trans_jan_ent_2',
        budgetId: 'budget_1',
        categoryId: 'entertainment',
        description: 'Game Purchase',
        amount: 45.00,
        type: TransactionType.expense,
        transactionDate: DateTime(2026, 1, 15),
        createdAt: DateTime(2026, 1, 15),
      ),

      // JANUARY EXPENSES - Shopping
      TransactionModel(
        id: 'trans_jan_shop_1',
        budgetId: 'budget_1',
        categoryId: 'shopping',
        description: 'Electronics',
        amount: 180.00,
        type: TransactionType.expense,
        transactionDate: DateTime(2026, 1, 3),
        createdAt: DateTime(2026, 1, 3),
      ),
      TransactionModel(
        id: 'trans_jan_shop_2',
        budgetId: 'budget_1',
        categoryId: 'shopping',
        description: 'Shoes',
        amount: 120.00,
        type: TransactionType.expense,
        transactionDate: DateTime(2026, 1, 22),
        createdAt: DateTime(2026, 1, 22),
      ),

      // JANUARY EXPENSES - Utilities
      TransactionModel(
        id: 'trans_jan_util_1',
        budgetId: 'budget_1',
        categoryId: 'utilities',
        description: 'Electricity Bill',
        amount: 75.00,
        type: TransactionType.expense,
        transactionDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
      ),
      TransactionModel(
        id: 'trans_jan_util_2',
        budgetId: 'budget_1',
        categoryId: 'utilities',
        description: 'Water Bill',
        amount: 35.00,
        type: TransactionType.expense,
        transactionDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
      ),
      TransactionModel(
        id: 'trans_jan_util_3',
        budgetId: 'budget_1',
        categoryId: 'utilities',
        description: 'Internet Bill',
        amount: 60.00,
        type: TransactionType.expense,
        transactionDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
      ),

      // JANUARY EXPENSES - Healthcare
      TransactionModel(
        id: 'trans_jan_health_1',
        budgetId: 'budget_1',
        categoryId: 'healthcare',
        description: 'Pharmacy',
        amount: 45.00,
        type: TransactionType.expense,
        transactionDate: DateTime(2026, 1, 9),
        createdAt: DateTime(2026, 1, 9),
      ),
      TransactionModel(
        id: 'trans_jan_health_2',
        budgetId: 'budget_1',
        categoryId: 'healthcare',
        description: 'Dental Checkup',
        amount: 60.00,
        type: TransactionType.expense,
        transactionDate: DateTime(2026, 1, 25),
        createdAt: DateTime(2026, 1, 25),
      ),
    ];

    for (final transaction in transactions) {
      await HiveBoxes.transactionsBox.add(transaction);
    }

    debugPrint('✅ January transactions created: ${transactions.length}');
  }
}
