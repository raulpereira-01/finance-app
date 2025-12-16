// Total de gastos agrupados por categoría para alimentar gráficos y resúmenes.
class CategoryExpense {
  final String categoryId;
  final double total;
  final int colorValue;
  final String emoji;

  const CategoryExpense({
    required this.categoryId,
    required this.total,
    required this.colorValue,
    required this.emoji,
  });
}
