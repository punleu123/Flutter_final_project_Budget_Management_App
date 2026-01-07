import 'package:hive_flutter/hive_flutter.dart';

part 'budget.g.dart';

/// Budget model for Hive storage
@HiveType(typeId: 2)
class Budget extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String userId;

  @HiveField(2)
  late String name;

  @HiveField(3)
  late double limitAmount;

  @HiveField(4)
  late String currency;

  @HiveField(5)
  late DateTime startDate;

  @HiveField(6)
  late DateTime endDate;

  @HiveField(7)
  late String status; // 'active', 'completed', 'paused'

  @HiveField(8)
  late DateTime createdAt;

  @HiveField(9)
  late DateTime? updatedAt;

  @HiveField(10)
  late String? description;

  Budget({
    required this.id,
    required this.userId,
    required this.name,
    required this.limitAmount,
    required this.currency,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.description,
  });

  /// Check if budget is currently active
  bool get isActive {
    final now = DateTime.now();
    return status == 'active' &&
        now.isAfter(startDate) &&
        now.isBefore(endDate);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'limitAmount': limitAmount,
      'currency': currency,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'description': description,
    };
  }

  /// Create from JSON
  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      limitAmount: (json['limitAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
      description: json['description'] as String?,
    );
  }

  @override
  String toString() => 'Budget(id: $id, name: $name, status: $status)';
}
