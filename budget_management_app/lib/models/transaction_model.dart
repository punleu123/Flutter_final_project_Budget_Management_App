import 'package:hive_flutter/hive_flutter.dart';
import 'transaction_type.dart';

part 'transaction_model.g.dart';

/// Transaction model for income/expense tracking
@HiveType(typeId: 1)
class TransactionModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String budgetId;

  @HiveField(2)
  late String categoryId;

  @HiveField(3)
  late String description;

  @HiveField(4)
  late double amount;

  @HiveField(5)
  late TransactionType type;

  @HiveField(6)
  late DateTime transactionDate;

  @HiveField(7)
  late DateTime createdAt;

  @HiveField(8)
  late DateTime? updatedAt;

  @HiveField(9)
  late String? notes;

  @HiveField(10)
  late String? paymentMethod;

  TransactionModel({
    required this.id,
    required this.budgetId,
    required this.categoryId,
    required this.description,
    required this.amount,
    required this.type,
    required this.transactionDate,
    required this.createdAt,
    this.updatedAt,
    this.notes,
    this.paymentMethod,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'budgetId': budgetId,
      'categoryId': categoryId,
      'description': description,
      'amount': amount,
      'type': type.name,
      'transactionDate': transactionDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'notes': notes,
      'paymentMethod': paymentMethod,
    };
  }

  /// Create from JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      budgetId: json['budgetId'] as String,
      categoryId: json['categoryId'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      type:
          json['type'] == 'income'
              ? TransactionType.income
              : TransactionType.expense,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
      notes: json['notes'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
    );
  }

  /// Copy with modified fields
  TransactionModel copyWith({
    String? id,
    String? budgetId,
    String? categoryId,
    String? description,
    double? amount,
    TransactionType? type,
    DateTime? transactionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    String? paymentMethod,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  @override
  String toString() =>
      'TransactionModel(id: $id, amount: $amount, type: ${type.name})';
}
