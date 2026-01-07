import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/hive_boxes.dart';
import '../models/category.dart';

/// Category notifier for CRUD operations on categories
class CategoryNotifier extends StateNotifier<CategoryState> {
  CategoryNotifier() : super(CategoryState(categories: [])) {
    loadCategories();
  }

  /// Load all categories from Hive
  void loadCategories() {
    final categories = HiveBoxes.categoriesBox.values.cast<Category>().toList();
    state = CategoryState(categories: categories);
  }

  /// Create a new category
  Future<void> createCategory(Category category) async {
    try {
      await HiveBoxes.categoriesBox.add(category);
      loadCategories();
    } catch (e) {
      rethrow;
    }
  }

  /// Get category by ID
  Category? getCategoryById(String id) {
    try {
      return state.categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Update an existing category
  Future<void> updateCategory(int index, Category category) async {
    try {
      await HiveBoxes.categoriesBox.putAt(index, category);
      loadCategories();
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a category
  Future<void> deleteCategory(int index) async {
    try {
      await HiveBoxes.categoriesBox.deleteAt(index);
      loadCategories();
    } catch (e) {
      rethrow;
    }
  }

  /// Delete category by ID
  Future<void> deleteCategoryById(String id) async {
    try {
      final index = state.categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        await HiveBoxes.categoriesBox.deleteAt(index);
        loadCategories();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get all categories
  List<Category> getAllCategories() => state.categories;

  /// Search categories by name
  List<Category> searchByName(String query) {
    return state.categories
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Get category count
  int getCategoryCount() => state.categories.length;

  /// Check if category exists
  bool categoryExists(String id) {
    return state.categories.any((c) => c.id == id);
  }
}

/// Category state
class CategoryState {
  final List<Category> categories;

  CategoryState({required this.categories});

  /// Copy with modified fields
  CategoryState copyWith({List<Category>? categories}) {
    return CategoryState(categories: categories ?? this.categories);
  }
}

/// Provider for category management
final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>(
  (ref) => CategoryNotifier(),
);

/// Provider to get all categories
final allCategoriesProvider = Provider<List<Category>>((ref) {
  return ref.watch(categoryProvider).categories;
});

/// Provider to get category by ID
final categoryByIdProvider = Provider.family<Category?, String>((ref, id) {
  return ref.watch(categoryProvider.notifier).getCategoryById(id);
});

/// Provider to search categories
final searchCategoriesProvider = Provider.family<List<Category>, String>((
  ref,
  query,
) {
  return ref.watch(categoryProvider.notifier).searchByName(query);
});

/// Provider to get category count
final categoryCountProvider = Provider<int>((ref) {
  return ref.watch(categoryProvider).categories.length;
});
