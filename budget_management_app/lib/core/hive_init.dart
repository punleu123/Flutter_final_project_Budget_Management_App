import 'package:hive_flutter/hive_flutter.dart';
import 'hive_boxes.dart';
import '../models/category.dart';
import '../models/transaction_model.dart';
import '../models/transaction_type.dart';
import '../models/category_budget_template.dart';
import '../models/monthly_category_budget.dart';

/// Hive initialization class
class HiveInit {
  /// Initialize Hive and register all adapters
  static Future<void> initialize() async {
    // Initialize Hive for Flutter
    await Hive.initFlutter();

    // Register all adapters in order of typeId
    Hive.registerAdapter(CategoryAdapter()); // typeId: 0
    Hive.registerAdapter(TransactionModelAdapter()); // typeId: 1
    // typeId: 2 reserved for Budget (not used)
    Hive.registerAdapter(CategoryBudgetTemplateAdapter()); // typeId: 3
    Hive.registerAdapter(MonthlyCategoryBudgetAdapter()); // typeId: 4
    Hive.registerAdapter(TransactionTypeAdapter()); // typeId: 5

    // Open all boxes
    await HiveBoxes.openAllBoxes();
  }

  /// Close all Hive boxes
  static Future<void> close() async {
    await Hive.close();
  }
}
