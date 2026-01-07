import 'package:hive_flutter/hive_flutter.dart';

part 'transaction_type.g.dart';

/// Transaction type enum for income/expense
@HiveType(typeId: 5)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}
