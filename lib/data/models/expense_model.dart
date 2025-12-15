import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 3)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final bool isFixed;

  @HiveField(5)
  final String categoryId;

  @HiveField(6)
  final bool isRecurring;

  /// Día del mes en el que se repite el gasto recurrente
  @HiveField(7)
  final int? dayOfMonth;

  /// Fecha desde la que comienza a repetirse (incluida)
  @HiveField(8)
  final DateTime? startDate;

  ExpenseModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.isFixed,
    required this.categoryId,
    this.isRecurring = false,
    this.dayOfMonth,
    this.startDate,
  });
}
