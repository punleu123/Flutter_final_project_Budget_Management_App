import 'package:hive_flutter/hive_flutter.dart';

/// Central place to manage all Hive boxes
class HiveBoxes {
  static late Box<dynamic> categoriesBox;
  static late Box<dynamic> transactionsBox;
  static late Box<dynamic> budgetsBox;
  static late Box<dynamic> categoryBudgetTemplateBox;
  static late Box<dynamic> monthlyCategoryBudgetBox;
  static late Box<dynamic> settingsBox;

  /// Open all required boxes
  static Future<void> openAllBoxes() async {
    categoriesBox = await Hive.openBox('categories');
    transactionsBox = await Hive.openBox('transactions');
    budgetsBox = await Hive.openBox('budgets');
    categoryBudgetTemplateBox = await Hive.openBox('categoryBudgetTemplate');
    monthlyCategoryBudgetBox = await Hive.openBox('monthlyCategoryBudget');
    settingsBox = await Hive.openBox('settings');
  }

  /// Clear all boxes (use with caution)
  static Future<void> clearAllBoxes() async {
    await categoriesBox.clear();
    await transactionsBox.clear();
    await budgetsBox.clear();
    await categoryBudgetTemplateBox.clear();
    await monthlyCategoryBudgetBox.clear();
    await settingsBox.clear();
  }

  /// Delete a specific box
  static Future<void> deleteBox(String boxName) async {
    await Hive.deleteBoxFromDisk(boxName);
  }
}
