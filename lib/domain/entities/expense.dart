// Entidad que modela un gasto, indicando si es fijo y la categoría asociada.
class Expense {
  final String id;
  final String name;
  final double amount;
  final DateTime date;
  final bool isFixed;
  final String categoryId;

  Expense({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.isFixed,
    required this.categoryId,
  });
}
