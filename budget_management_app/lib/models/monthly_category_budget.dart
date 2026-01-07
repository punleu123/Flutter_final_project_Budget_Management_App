import 'package:hive_flutter/hive_flutter.dart';

part 'monthly_category_budget.g.dart';

/// Monthly override for category budget (takes precedence over template)
@HiveType(typeId: 4)
class MonthlyCategoryBudget extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String categoryId;

  @HiveField(2)
  late int month; // 1-12

  @HiveField(3)
  late int year; // e.g., 2024

  @HiveField(4)
  late double targetAmount;

  @HiveField(5)
  late DateTime createdAt;

  @HiveField(6)
  late DateTime? updatedAt;

  MonthlyCategoryBudget({
    required this.id,
    required this.categoryId,
    required this.month,
    required this.year,
    required this.targetAmount,
    required this.createdAt,
    this.updatedAt,
  });

  /// Get unique key for this monthly budget
  String get key => '${categoryId}_${year}_${month.toString().padLeft(2, '0')}';

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'month': month,
      'year': year,
      'targetAmount': targetAmount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory MonthlyCategoryBudget.fromJson(Map<String, dynamic> json) {
    return MonthlyCategoryBudget(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      month: json['month'] as int,
      year: json['year'] as int,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
    );
  }

  /// Copy with modified fields
  MonthlyCategoryBudget copyWith({
    String? id,
    String? categoryId,
    int? month,
    int? year,
    double? targetAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MonthlyCategoryBudget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      month: month ?? this.month,
      year: year ?? this.year,
      targetAmount: targetAmount ?? this.targetAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'MonthlyCategoryBudget($year-${month.toString().padLeft(2, '0')}, category: $categoryId, target: $targetAmount)';
}
