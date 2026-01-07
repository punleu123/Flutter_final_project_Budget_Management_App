import 'package:hive_flutter/hive_flutter.dart';

part 'category_budget_template.g.dart';

/// Category budget template for default spending limits
@HiveType(typeId: 3)
class CategoryBudgetTemplate extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String categoryId;

  @HiveField(2)
  late double targetAmount;

  @HiveField(3)
  late DateTime createdAt;

  @HiveField(4)
  late DateTime? updatedAt;

  CategoryBudgetTemplate({
    required this.id,
    required this.categoryId,
    required this.targetAmount,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'targetAmount': targetAmount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory CategoryBudgetTemplate.fromJson(Map<String, dynamic> json) {
    return CategoryBudgetTemplate(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
    );
  }

  /// Copy with modified fields
  CategoryBudgetTemplate copyWith({
    String? id,
    String? categoryId,
    double? targetAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryBudgetTemplate(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      targetAmount: targetAmount ?? this.targetAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'CategoryBudgetTemplate(categoryId: $categoryId, target: $targetAmount)';
}
