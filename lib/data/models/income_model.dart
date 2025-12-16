// Modelo de Hive para persistir ingresos recurrentes o puntuales.
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
  final DateTime startDate;

  /// Día del mes en el que se registra este ingreso de manera recurrente.
  @HiveField(4)
  final int dayOfMonth;

  IncomeModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.startDate,
    required this.dayOfMonth,
  });
}
