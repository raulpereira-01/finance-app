import 'package:hive/hive.dart';

part 'income_model.g.dart';

@HiveType(typeId: 2)
class IncomeModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  IncomeModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
  });
}
