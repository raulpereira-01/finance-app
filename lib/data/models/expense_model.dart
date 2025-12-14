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

  ExpenseModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.isFixed,
    required this.categoryId,
  });
}
